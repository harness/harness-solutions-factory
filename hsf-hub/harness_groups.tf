locals {
  // Path to user groups template directory
  groups_files_path = "${local.source_directory}/groups"

  // Load all YAML group definition files from templates
  group_files = fileset("${local.groups_files_path}/", "*.yaml")

  // Parse group definitions and normalize identifiers (remove file extension, replace spaces/dashes with underscores)
  all_groups = flatten([
    for group_file in local.group_files : [
      merge(
        yamldecode(file("${local.groups_files_path}/${group_file}")),
        {
          identifier = replace(replace(replace(group_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(group_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])

  // Filter for new groups to create (no prefix = project-level)
  groups = flatten([
    for group in local.all_groups : [
      group
    ] if !startswith(group.identifier, "_") && !startswith(group.identifier, "account_") && !startswith(group.identifier, "org_")
  ])

  // Filter for existing project-level groups (underscore prefix = existing, not managed)
  existing_groups = flatten([
    for group in local.all_groups : [
      group
    ] if startswith(group.identifier, "_")
  ])

  // Filter for existing account-level groups (reference only, no management)
  existing_groups_account = flatten([
    for group in local.all_groups : [
      {
        identifier = replace(group.identifier, "account_", "")
      }
    ] if startswith(group.identifier, "account_")
  ])

  // Filter for existing org-level groups (reference only, no management)
  existing_groups_org = flatten([
    for group in local.all_groups : [
      {
        identifier = replace(group.identifier, "org_", "")
      }
    ] if startswith(group.identifier, "org_")
  ])

  // Flatten role bindings from each group with complete binding metadata
  groups_bindings = flatten([
    for group in local.all_groups : [
      for binding in lookup(group, "role_bindings", []) : {
        identifier       = "${group.identifier}_${lookup(binding, "role", "MISSING-ROLE-ID")}_${lookup(binding, "resource_group", "MISSING-RESOURCE-GROUP-ID")}"
        deprecated_id    = "${group.identifier}_${lookup(binding, "role", "MISSING-ROLE-ID")}"
        group_identifier = replace(replace(group.identifier, "account_", ""), "org_", "")
        group_name       = group.name
        role             = lookup(binding, "role", "MISSING-ROLE")
        resource_group   = lookup(binding, "resource_group", "MISSING-ROLE")
        // Determine scope level based on group identifier prefix
        scope_level = (
          startswith(group.identifier, "account_")
          ?
          "account"
          :
          startswith(group.identifier, "org_")
          ?
          "org"
          :
          "project"
        )
      }
    ]
  ])
}

// Fetch existing account-level user groups (reference only)
data "harness_platform_usergroup" "account_usergroup" {
  for_each = {
    for group in local.existing_groups_account : group.identifier => group
  }
  identifier = each.value.identifier
}

// Fetch existing org-level user groups (reference only)
data "harness_platform_usergroup" "org_usergroup" {
  for_each = {
    for group in local.existing_groups_org : group.identifier => group
  }
  identifier = each.value.identifier
  org_id     = data.harness_platform_organization.selected.id
}

// Fetch existing project-level user groups (reference only)
data "harness_platform_usergroup" "usergroup" {
  for_each = {
    for group in local.existing_groups : group.identifier => group
  }
  identifier = each.value.identifier
  org_id     = data.harness_platform_organization.selected.id
  project_id = data.harness_platform_project.selected.id
}

// Create new user groups for HSF Hub project
resource "harness_platform_usergroup" "usergroup" {
  depends_on = [harness_platform_roles.role, harness_platform_resource_group.resource_group]
  // Ignore user management and SSO linking (managed externally)
  lifecycle {
    ignore_changes = [
      users,
      user_emails,
      linked_sso_id,
      linked_sso_display_name,
      linked_sso_type,
      notification_configs,
      sso_linked,
      sso_group_id,
      sso_group_name
    ]
  }
  for_each = {
    for group in local.groups : group.identifier => group
  }

  identifier  = each.value.identifier
  name        = each.value.name
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = lookup(each.value, "description", "Harness UserGroup managed by Solutions Factory")
  user_emails = []

  externally_managed      = false
  linked_sso_id           = lookup(each.value, "linked_sso_id", null)
  linked_sso_display_name = lookup(each.value, "linked_sso_id", null)
  linked_sso_type         = lookup(each.value, "linked_sso_type", null)
  sso_linked              = lookup(each.value, "sso_group_id", null) != null ? true : false
  sso_group_id            = lookup(each.value, "sso_group_id", null)
  sso_group_name          = lookup(each.value, "sso_group_id", null)

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}

// Assign roles and permissions to user groups
resource "harness_platform_role_assignments" "usergroup_bindings" {
  depends_on = [harness_platform_usergroup.usergroup]
  for_each = {
    for group in local.groups_bindings : group.identifier => group
  }

  identifier                = each.value.identifier
  org_id                    = data.harness_platform_organization.selected.id
  project_id                = data.harness_platform_project.selected.id
  resource_group_identifier = each.value.resource_group
  role_identifier           = each.value.role

  // Try multiple lookups to find group in new, existing project, org, or account scopes
  principal {
    identifier = try(
      harness_platform_usergroup.usergroup[each.value.group_identifier].id,
      harness_platform_usergroup.usergroup[each.value.group_name].id,
      data.harness_platform_usergroup.usergroup[each.value.group_identifier].id,
      data.harness_platform_usergroup.org_usergroup[each.value.group_identifier].id,
      data.harness_platform_usergroup.account_usergroup[each.value.group_identifier].id
    )
    scope_level = each.value.scope_level
    type        = "USER_GROUP"
  }
  disabled = false
  managed  = false
}

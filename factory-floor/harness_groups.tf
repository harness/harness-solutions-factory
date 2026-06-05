// User group management with role bindings and RBAC assignments

// Load group definition files from templates directory
locals {
  groups_files_path = "${local.source_directory}/groups"

  group_files = fileset("${local.groups_files_path}/", "*.yaml")

  // Parse all group definitions and normalize identifiers/names
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

  // Filter groups by scope: create new project-level groups
  groups = flatten([
    for group in local.all_groups : [
      group
    ] if !startswith(group.identifier, "_") && !startswith(group.identifier, "account_") && !startswith(group.identifier, "org_")
  ])

  // Filter existing internal groups (underscore prefix)
  existing_groups = flatten([
    for group in local.all_groups : [
      group
    ] if startswith(group.identifier, "_")
  ])

  // Filter account-scoped references
  existing_groups_account = flatten([
    for group in local.all_groups : [
      {
        identifier = replace(group.identifier, "account_", "")
      }
    ] if startswith(group.identifier, "account_")
  ])

  // Filter organization-scoped references
  existing_groups_org = flatten([
    for group in local.all_groups : [
      {
        identifier = replace(group.identifier, "org_", "")
      }
    ] if startswith(group.identifier, "org_")
  ])

  // Transform role bindings for group-role-resource_group combinations
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

// Fetch account-scoped user groups for reference
data "harness_platform_usergroup" "account_usergroup" {
  for_each = {
    for group in local.existing_groups_account : group.identifier => group
  }
  identifier = each.value.identifier
}

// Fetch organization-scoped user groups for reference
data "harness_platform_usergroup" "org_usergroup" {
  for_each = {
    for group in local.existing_groups_org : group.identifier => group
  }
  identifier = each.value.identifier
  org_id     = data.harness_platform_organization.selected.id
}

// Fetch project-scoped user groups for reference
data "harness_platform_usergroup" "usergroup" {
  for_each = {
    for group in local.existing_groups : group.identifier => group
  }
  identifier = each.value.identifier
  org_id     = data.harness_platform_organization.selected.id
  project_id = data.harness_platform_project.selected.id
}

// Create or update user groups with external management and notification settings
resource "harness_platform_usergroup" "usergroup" {
  depends_on = [harness_platform_roles.roles, harness_platform_resource_group.resource_groups]

  for_each = {
    for group in local.groups : group.identifier => group
  }

  identifier = each.value.identifier
  name       = each.value.name
  org_id     = data.harness_platform_organization.selected.id
  project_id = data.harness_platform_project.selected.id
  description = lookup(each.value, "description", "Harness UserGroup managed by Solutions Factory")
  user_emails = []

  externally_managed      = false
  linked_sso_id           = lookup(each.value, "linked_sso_id", null)
  linked_sso_display_name = lookup(each.value, "linked_sso_id", null)
  linked_sso_type         = lookup(each.value, "linked_sso_type", null)
  sso_linked              = lookup(each.value, "sso_group_id", null) != null ? true : false
  sso_group_id            = lookup(each.value, "sso_group_id", null)
  sso_group_name          = lookup(each.value, "sso_group_id", null)

  // Allow manual updates to group members managed by SSO or external systems
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

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}

// Assign roles to user groups at the appropriate scope level
resource "harness_platform_role_assignments" "usergroup_bindings" {
  depends_on = [harness_platform_usergroup.usergroup]

  for_each = {
    for group in local.groups_bindings : group.identifier => group
  }

  identifier = each.value.identifier
  org_id     = data.harness_platform_organization.selected.id
  project_id = data.harness_platform_project.selected.id

  resource_group_identifier = each.value.resource_group
  role_identifier           = each.value.role

  // Resolve group principal by trying multiple scopes (project → org → account)
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

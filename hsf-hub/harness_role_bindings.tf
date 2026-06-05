locals {
  // File names to search for role binding definitions in hubs
  role_binding_file_names = [
    ".harness/rb_hsf_hub.yaml",
    ".harness/additional/rb_hsf_hub.yaml"
  ]

  // Find all role binding definition files across hub paths
  role_binding_file_paths = flatten([
    for entity_dir in local.hub_paths : {
      "${entity_dir}" = flatten([
        for file_name in local.role_binding_file_names : [
          fileset("${entity_dir}/", file_name),
        ]
      ])
    }
  ])

  // Parse all role binding YAML files and extract definitions
  role_bindings_all = flatten([
    for content_library_obj in local.role_binding_file_paths : [
      for content_library, hubs in content_library_obj : [
        for hub in hubs : [
          merge(
            yamldecode(file("${content_library}/${hub}")),
            {
              file_path = "${content_library}/${hub}"
              // Generate identifier from hub path (distinguish additional configs with suffix)
              identifier = replace((
                contains(split("/", hub), "additional")
                ?
                join("_", [reverse(split("/", content_library))[0], "additional"])
                :
                reverse(split("/", content_library))[0]
              ), "-", "_")
            }
          )
        ]
      ]
    ]
  ])

  // Flatten role bindings with normalized identifiers and scope levels
  role_bindings = flatten([
    for role_binding in local.role_bindings_all : [
      for binding in role_binding.role_bindings : [
        merge(
          binding,
          {
            // Create composite identifier from hub, group, role, and resource group
            identifier = lower(join("_", [
              role_binding.identifier,
              replace(lookup(binding, "group_id", "MissingGroupId"), ".", "_"),
              lookup(binding, "role", "MissingRoleId"),
              lookup(binding, "resource_group", "MissingResourceGroupId")
            ]))
            name = lower(join("_", [
              role_binding.identifier,
              replace(lookup(binding, "group_id", "MissingGroupId"), ".", "_"),
              lookup(binding, "role", "MissingRoleId"),
              lookup(binding, "resource_group", "MissingResourceGroupId")
            ]))
            // Strip scope prefixes from group ID
            group_id = replace(replace(binding.group_id, "account.", ""), "org.", "")
            // Determine scope level based on group_id prefix
            scope_level = (
              startswith(binding.group_id, "account.")
              ?
              "account"
              :
              startswith(binding.group_id, "org.")
              ?
              "org"
              :
              "project"
            )
          }
        )
      ]
    ]
  ])

  // Filter project-level group role bindings
  lz_existing_groups = flatten([
    for group in local.role_bindings : [
      {
        identifier = group.identifier
        group_id   = group.group_id
      }
    ] if group.scope_level == "project"
  ])

  // Filter account-level group role bindings
  lz_existing_groups_account = flatten([
    for group in local.role_bindings : [
      {
        identifier = group.identifier
        group_id   = replace(group.group_id, "account.", "")
      }
    ] if group.scope_level == "account"
  ])

  // Filter org-level group role bindings
  lz_existing_groups_org = flatten([
    for group in local.role_bindings : [
      {
        identifier = group.identifier
        group_id   = replace(group.group_id, "org.", "")
      }
    ] if group.scope_level == "org"
  ])
}

// Fetch existing account-level user groups for role binding (reference only)
data "harness_platform_usergroup" "lz_account_usergroup" {
  depends_on = [harness_platform_usergroup.usergroup]
  for_each = {
    for group in local.lz_existing_groups_account : group.identifier => group
  }
  identifier = each.value.group_id
}

// Fetch existing org-level user groups for role binding (reference only)
data "harness_platform_usergroup" "lz_org_usergroup" {
  depends_on = [harness_platform_usergroup.usergroup]
  for_each = {
    for group in local.lz_existing_groups_org : group.identifier => group
  }
  identifier = each.value.group_id
  org_id     = data.harness_platform_organization.selected.id
}

// Fetch existing project-level user groups for role binding (reference only)
data "harness_platform_usergroup" "lz_usergroup" {
  depends_on = [harness_platform_usergroup.usergroup]
  for_each = {
    for group in local.lz_existing_groups : group.identifier => group
  }
  identifier = each.value.group_id
  org_id     = data.harness_platform_organization.selected.id
  project_id = data.harness_platform_project.selected.id
}

// Assign roles to groups based on hub configuration
resource "harness_platform_role_assignments" "lz_usergroup_bindings" {
  depends_on = [
    harness_platform_usergroup.usergroup,
    data.harness_platform_usergroup.lz_account_usergroup,
    data.harness_platform_usergroup.lz_org_usergroup,
    data.harness_platform_usergroup.lz_usergroup,
  ]
  for_each = {
    for group in local.role_bindings : group.identifier => group
  }

  identifier                = each.value.identifier
  org_id                    = data.harness_platform_organization.selected.id
  project_id                = data.harness_platform_project.selected.id
  resource_group_identifier = each.value.resource_group
  role_identifier           = each.value.role

  // Try multiple lookups to find group in new, existing project, org, or account scopes
  principal {
    identifier = try(
      harness_platform_usergroup.usergroup[each.value.group_id].id,
      data.harness_platform_usergroup.lz_usergroup[each.value.identifier].id,
      data.harness_platform_usergroup.lz_org_usergroup[each.value.identifier].id,
      data.harness_platform_usergroup.lz_account_usergroup[each.value.identifier].id
    )
    scope_level = each.value.scope_level
    type        = "USER_GROUP"
  }
  disabled = false
  managed  = false
}

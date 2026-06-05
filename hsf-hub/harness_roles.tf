locals {
  // Path to role definitions directory
  roles_files_path = "${local.source_directory}/roles"

  // Load all YAML role definition files
  role_files = fileset("${local.roles_files_path}/", "*.yaml")

  // Parse role definitions and normalize names (remove .yaml extension)
  roles = flatten([
    for role_file in local.role_files : [
      merge(
        yamldecode(file("${local.roles_files_path}/${role_file}")),
        {
          name = replace(role_file, ".yaml", "")
        }
      )
    ]
  ])

  // Valid permission statuses for roles (excludes DEPRECATED or other non-usable statuses)
  permission_statuses = [
    "ACTIVE",
    "EXPERIMENTAL"
  ]

  // Fetch and cache all valid project-level permissions in sorted order
  project_permission_identifiers = sort(compact(flatten([
    for permission in data.harness_platform_permissions.current.permissions : [
      permission.identifier
    ] if contains(local.permission_statuses, permission.status) && contains(permission.allowed_scope_levels, "project")
  ])))

  // Validate role permissions - map role names to list of invalid permission IDs
  invalid_project_permissions = merge({
    for role in local.roles :
    (role.name) => flatten([
      for permission in role.permissions : [
        permission
      ] if !contains(local.project_permission_identifiers, permission)
    ])
  })
}

// Create custom roles with specified permissions for HSF Hub
resource "harness_platform_roles" "role" {
  for_each = {
    for role in local.roles : role.name => role
  }
  // Validate that all permissions in role definition are valid for project scope
  lifecycle {
    precondition {
      condition     = length(local.invalid_project_permissions[each.key]) == 0
      error_message = <<EOF
      [Invalid] The following permissions are invalid for this role - ${each.key}.
      - ${join("\n      - ", local.invalid_project_permissions[each.key])}
      EOF
    }
  }

  identifier           = replace(replace(each.value.name, " ", "_"), "-", "_")
  name                 = each.value.name
  org_id               = data.harness_platform_organization.selected.id
  project_id           = data.harness_platform_project.selected.id
  allowed_scope_levels = ["project"]

  // List of valid permission identifiers (see https://apidocs.harness.io/tag/Permissions#operation/getPermissionList)
  permissions = each.value.permissions

  tags = local.common_tags_tuple
}

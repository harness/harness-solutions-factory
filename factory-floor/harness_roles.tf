// Custom role definitions for factory-floor RBAC

// Load role definition files from templates directory
locals {
  roles_files_path = "${local.source_directory}/roles"

  role_files = fileset("${local.roles_files_path}/", "*.yaml")

  // Parse YAML role definitions and add filename as role name
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
}

// Create custom roles with specific permission sets for workspace operations
resource "harness_platform_roles" "roles" {
  for_each = {
    for role in local.roles : role.name => role
  }

  identifier = replace(replace(each.value.name, " ", "_"), "-", "_")

  name                 = each.value.name
  org_id               = var.organization_id
  project_id           = var.project_id
  allowed_scope_levels = ["project"]

  // Harness permission identifiers (see: https://apidocs.harness.io/tag/Permissions)
  permissions = each.value.permissions

  tags = local.common_tags_tuple
}

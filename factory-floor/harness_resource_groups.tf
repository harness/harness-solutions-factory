// Resource group definitions for scoped access control

// Load resource group definition files from templates directory
locals {
  resource_groups_files_path = "${local.source_directory}/resource_groups"

  resource_group_files = fileset("${local.resource_groups_files_path}/", "*.yaml")

  // Parse YAML resource group definitions and add filename as group name
  resource_groups = flatten([
    for resource_group_file in local.resource_group_files : [
      merge(
        yamldecode(file("${local.resource_groups_files_path}/${resource_group_file}")),
        {
          name = replace(resource_group_file, ".yaml", "")
        }
      )
    ]
  ])
}

// Create resource groups with dynamic filtering for workspace access control
resource "harness_platform_resource_group" "resource_groups" {
  for_each = {
    for resource_group in local.resource_groups : resource_group.name => resource_group
  }

  identifier = replace(replace(each.value.name, " ", "_"), "-", "_")

  name        = each.value.name
  description = lookup(each.value, "description", "Harness ResourceGroup managed by Solutions Factory")
  account_id  = var.harness_platform_account
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id

  allowed_scope_levels = ["project"]

  // Define resource scope to project level
  included_scopes {
    filter     = "EXCLUDING_CHILD_SCOPES"
    account_id = var.harness_platform_account
    org_id     = data.harness_platform_organization.selected.id
    project_id = data.harness_platform_project.selected.id
  }

  // Apply resource filters based on type, identifiers, and attributes
  resource_filter {
    include_all_resources = lookup(each.value, "resource_filters", null) != null ? false : true

    dynamic "resources" {
      for_each = lookup(each.value, "resource_filters", [])
      content {
        resource_type = lookup(resources.value, "type", null)
        identifiers   = lookup(resources.value, "identifiers", null)

        // Filter resources by attribute name/value pairs
        dynamic "attribute_filter" {
          for_each = lookup(resources.value, "filters", [])
          content {
            attribute_name   = lookup(attribute_filter.value, "name", null)
            attribute_values = flatten([lookup(attribute_filter.value, "values", [])])
          }
        }
      }
    }
  }

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}

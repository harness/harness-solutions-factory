locals {
  // File names to search for resource group definitions in hubs
  resource_groups_file_names = [
    ".harness/rg_hsf_hub.yaml",
    ".harness/additional/rg_hsf_hub.yaml"
  ]

  // Find all resource group definition files across hub paths
  resource_groups_files_paths = flatten([
    for entity_dir in local.hub_paths : {
      "${entity_dir}" = flatten([
        for file_name in local.resource_groups_file_names : [
          fileset("${entity_dir}/", file_name),
        ]
      ])
    }
  ])

  // Parse all resource group YAML files and extract definitions
  resource_groups_all = flatten([
    for content_library_obj in local.resource_groups_files_paths : [
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

  // Normalize resource groups by extracting ID field
  resource_groups = flatten([
    for resource_group in local.resource_groups_all : [
      merge(
        resource_group,
        {
          identifier = lookup(resource_group, "id", "MISSING-ID")
          name       = lookup(resource_group, "id", "MISSING-ID")
        }
      )
    ]
  ])
}

// Create resource groups for HSF Hub that control access to hub pipelines
resource "harness_platform_resource_group" "resource_group" {
  depends_on = [harness_platform_pipeline.hubs]
  for_each = {
    for resource_group in local.resource_groups : resource_group.identifier => resource_group
  }

  identifier  = replace(replace(each.value.name, " ", "_"), "-", "_")
  name        = each.value.name
  description = lookup(each.value, "description", "Harness ResourceGroup managed by Solutions Factory")
  account_id  = var.harness_platform_account
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])

  allowed_scope_levels = ["project"]
  included_scopes {
    filter     = "EXCLUDING_CHILD_SCOPES"
    account_id = var.harness_platform_account
    org_id     = data.harness_platform_organization.selected.id
    project_id = data.harness_platform_project.selected.id
  }
  resource_filter {
    include_all_resources = lookup(each.value, "resource_filters", null) != null ? false : true
    dynamic "resources" {
      for_each = lookup(each.value, "resource_filters", [])
      content {
        // Harness resource type (pipeline, environment, deployment, etc.)
        resource_type = lookup(resources.value, "type", null)
        // Resource identifiers to include in this group
        identifiers = lookup(resources.value, "identifiers", null)
        dynamic "attribute_filter" {
          for_each = lookup(resources.value, "filters", [])
          content {
            // Attribute name to filter on (e.g., tags, labels)
            attribute_name = lookup(attribute_filter.value, "name", null)
            // Attribute values to match
            attribute_values = flatten([lookup(attribute_filter.value, "values", [])])
          }
        }
      }
    }
  }
}

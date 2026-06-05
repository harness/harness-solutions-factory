locals {
  // File names to search for hub pipeline definitions
  hub_file_names = [
    ".harness/pipe_hsf_hub.yaml",
    ".harness/additional/pipe_hsf_hub.yaml"
  ]

  // Find all hub pipeline definition files across registered entities
  hub_pipelines_paths = flatten([
    for entity_dir in local.registration_mgr_entities : {
      "${entity_dir}" = flatten([
        for file_name in local.hub_file_names : [
          fileset("${local.content_library}/", join("/", [entity_dir, file_name]))
        ]
      ])
    }
  ])

  // Parse all hub pipeline YAML files and extract definitions
  hub_pipelines = flatten([
    for hubs in local.hub_pipelines_paths : [
      for entity_dir, hub in hubs : [
        for entity_file in hub : [
          merge(
            yamldecode(file("${local.content_library}/${entity_file}")),
            {
              content_library = local.content_library
              file_path       = "${local.content_library}/${entity_file}"
              lz_dir          = entity_dir
              // Generate identifier from entity path (distinguish additional configs by name)
              identifier = replace((
                contains(split("/", entity_file), "additional")
                ?
                join("_", [split("/", entity_file)[0], split("/", entity_file)[2]])
                :
                split("/", entity_file)[0]
              ), "-", "_")
            }
          )
        ]
      ]
    ]
  ])

  // Extract unique content library paths for resource group and role binding lookups
  hub_paths = distinct(flatten([
    for hub in local.hub_pipelines : [
      join("/", [hub.content_library, hub.lz_dir])
    ]
  ]))
}

// Create deployment pipelines for HSF Hub with template variable interpolation
resource "harness_platform_pipeline" "hubs" {
  for_each = {
    for hub in local.hub_pipelines : hub.identifier => hub
  }
  identifier  = each.value.pipeline.identifier
  name        = each.value.pipeline.name
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = lookup(each.value.pipeline, "description", null)
  tags        = [for k, v in lookup(each.value.pipeline, "tags", {}) : "${k}:${v}"]
  // Render pipeline YAML with Harness organization, project, and workspace management details
  yaml = templatefile(
    each.value.file_path,
    {
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      WORKSPACE_MGMT_ORG_ID : var.workspace_mgmt_organization_id
      WORKSPACE_MGMT_PROJECT_ID : var.workspace_mgmt_project_id
      WORKSPACE_MGMT_PIPELINE_ID : var.workspace_mgmt_pipeline_id
      SHOULD_USE_HARNESS_IDP : local.should_use_harness_idp
    }
  )
}

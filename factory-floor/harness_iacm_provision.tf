// Provision infrastructure pipeline for applying IACM workspace changes
// Pipeline that provisions infrastructure by applying IACM workspace changes
resource "harness_platform_pipeline" "Provision_IACM_Workspace" {
  lifecycle {
    precondition {
      // Validate that all required factory floor variables are set before creating pipeline
      condition     = length(local.invalid_factory_floor_variables) == 0
      error_message = "Null values found for keys: ${join(", ", local.invalid_factory_floor_variables)}"
    }
  }
  identifier  = "Provision_Workspace"
  name        = "Provision Workspace"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "HSF provided pipeline intended to Provision an IACM workspace"

  // Load pipeline YAML template with workspace and infrastructure configuration
  yaml = templatefile(
    "${path.module}/templates/pipelines/Provision_IACM_Workspace.yaml",
    {
      PIPELINE_IDENTIFIER : "Provision_Workspace"
      PIPELINE_NAME : "Provision Workspace"
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "HSF provided pipeline intended to Provision an IACM workspace"
      KUBERNETES_IMAGE_NAME : local.factory_floor_variables.kubernetes_override_image_name

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE

      HARNESS_PLATFORM_KEY : local.factory_floor_variables.existing_harness_platform_key_ref
      DOCKER_REGISTRY_ID : local.factory_floor_variables.hsf_pipeline_connector_ref
      HSF_IDP_RESOURCE_MGR_IMAGE : local.factory_floor_variables.hsf_idp_resource_mgr_image
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (local.factory_floor_variables.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      TAGS : yamlencode(merge(local.common_tags, { purpose : "manual_execution" }))

      USE_HARNESS_IDP : local.factory_floor_variables.should_use_harness_idp ? "true" : "skipped"
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["purpose:manual_execution"]
  ])
}

// Set Provision as default pipeline for IACM workspace apply operations
resource "harness_platform_iacm_default_pipeline" "provision_defaults" {
  org_id           = data.harness_platform_organization.selected.id
  project_id       = data.harness_platform_project.selected.id
  provisioner_type = "opentofu"
  pipeline         = harness_platform_pipeline.Provision_IACM_Workspace.id
  operation        = "apply"
}

// Plan and validate pipeline for reviewing infrastructure changes before apply
// Pipeline that plans and validates infrastructure changes before applying them
resource "harness_platform_pipeline" "Plan_and_Validate_IACM_Workspace" {
  lifecycle {
    precondition {
      // Validate that all required factory floor variables are set before creating pipeline
      condition     = length(local.invalid_factory_floor_variables) == 0
      error_message = "Null values found for keys: ${join(", ", local.invalid_factory_floor_variables)}"
    }
  }
  identifier  = "Plan_and_Validate_IACM_Workspace"
  name        = "Plan and Validate IACM Workspace"
  org_id      = var.organization_id
  project_id  = var.project_id
  description = "HSF provided pipeline intended to Plan and Validate against an IACM workspace"
  // Load pipeline YAML template with workspace and infrastructure configuration
  yaml = templatefile(
    "${path.module}/templates/pipelines/Plan_and_Validate_IACM_Workspace.yaml",
    {
      PIPELINE_IDENTIFIER : "Plan_and_Validate_IACM_Workspace"
      PIPELINE_NAME : "Plan and Validate IACM Workspace"
      ORGANIZATION_ID : var.organization_id
      PROJECT_ID : var.project_id
      DESCRIPTION : "HSF provided pipeline intended to Plan and Validate against an IACM workspace"
      KUBERNETES_IMAGE_NAME : local.factory_floor_variables.kubernetes_override_image_name

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE

      HARNESS_PLATFORM_KEY : local.factory_floor_variables.existing_harness_platform_key_ref
      DOCKER_REGISTRY_ID : local.factory_floor_variables.hsf_pipeline_connector_ref
      HSF_IDP_RESOURCE_MGR_IMAGE : local.factory_floor_variables.hsf_idp_resource_mgr_image
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (local.factory_floor_variables.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      TAGS : yamlencode(merge(local.common_tags, { purpose : "plan_and_validate_workspace" }))

      USE_HARNESS_IDP : local.factory_floor_variables.should_use_harness_idp ? "true" : "skipped"
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["purpose:plan_and_validate_workspace"]
  ])
}

// Set Plan/Validate as default pipeline for IACM workspace plan operations
resource "harness_platform_iacm_default_pipeline" "plan_defaults" {
  org_id           = var.organization_id
  project_id       = var.project_id
  provisioner_type = "opentofu"
  pipeline         = harness_platform_pipeline.Plan_and_Validate_IACM_Workspace.id
  operation        = "plan"
}

// Bulk workspace management pipeline for tag-based operations
// Pipeline that enables bulk operations against IACM Workspaces
resource "harness_platform_pipeline" "Bulk_Workspace_Management" {
  lifecycle {
    precondition {
      // Validate that all required factory floor variables are set before creating pipeline
      condition     = length(local.invalid_factory_floor_variables) == 0
      error_message = "Null values found for keys: ${join(", ", local.invalid_factory_floor_variables)}"
    }
  }
  identifier  = "Bulk_Workspace_Management"
  name        = "Bulk Workspace Management"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "Pipeline to handle bulk actions against IACM Workspaces"
  // Load pipeline YAML template with workspace and infrastructure configuration
  yaml = templatefile(
    "${path.module}/templates/pipelines/Bulk_Workspace_Management.yaml",
    {
      PIPELINE_IDENTIFIER : "Bulk_Workspace_Management"
      PIPELINE_NAME : "Bulk Workspace Management"
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "Pipeline to handle bulk actions against IACM Workspaces"

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      IDP_STAGE_INFRASTRUCTURE : local.IDP_STAGE_INFRASTRUCTURE

      HARNESS_PLATFORM_API_KEY : local.factory_floor_variables.existing_harness_platform_key_ref

      DOCKER_REGISTRY_ID : local.factory_floor_variables.hsf_pipeline_connector_ref
      HSF_SCRIPT_MGR_IMAGE : local.factory_floor_variables.hsf_script_mgr_image
      HSF_IACM_WORKSPACE_MGR_IMAGE : local.factory_floor_variables.hsf_iacm_manager_plugin
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (local.factory_floor_variables.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      USE_HARNESS_IDP : local.factory_floor_variables.should_use_harness_idp ? "true" : "skipped"
      HSF_CORE_MANAGER : local.hsf_core_mgr_workspace

      TAGS : yamlencode(merge(local.common_tags, { factory_floor : "false" }))
    }
  )
  tags = flatten([[for k, v in merge(local.common_tags, { factory_floor : "false" }) : "${k}:${v}"]])
}

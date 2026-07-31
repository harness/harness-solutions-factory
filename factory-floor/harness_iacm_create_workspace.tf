// Create and manage IACM workspace pipeline for initial setup and configuration
// Pipeline that creates and manages Harness IACM Workspaces along with IDP resource registration
resource "harness_platform_pipeline" "Create_and_Manage_IACM_Workspace" {
  lifecycle {
    precondition {
      // Validate that all required factory floor variables are set before creating pipeline
      condition     = length(local.invalid_factory_floor_variables) == 0
      error_message = "Null values found for keys: ${join(", ", local.invalid_factory_floor_variables)}"
    }
  }
  identifier  = "Create_and_Manage_IACM_Workspaces"
  name        = "Create and Manage IACM Workspaces"
  org_id      = var.organization_id
  project_id  = var.project_id
  description = "Pipeline designed to create and manage Harness IACM Workspaces along with IDP resource registration"
  // Load pipeline YAML template with workspace and infrastructure configuration
  yaml = templatefile(
    "${path.module}/templates/pipelines/Create_and_Manage_IACM_Workspaces.yaml",
    {
      PIPELINE_IDENTIFIER : "Create_and_Manage_IACM_Workspaces"
      PIPELINE_NAME : "Create and Manage IACM Workspaces"
      ORGANIZATION_ID : var.organization_id
      PROJECT_ID : var.project_id
      DESCRIPTION : "Pipeline designed to create and manage Harness IACM Workspaces along with IDP resource registration"

      KUBERNETES_IMAGE_NAME : local.factory_floor_variables.kubernetes_override_image_name

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      IDP_STAGE_INFRASTRUCTURE : local.IDP_STAGE_INFRASTRUCTURE

      GIT_REPOSITORY_BRANCH : local.factory_floor_variables.git_repository_branch
      GIT_REPOSITORY_CONNECTOR : local.factory_floor_variables.git_connector_ref
      GIT_REPOSITORY_NAME : local.factory_floor_variables.git_repository_name

      HARNESS_PLATFORM_API_KEY : local.factory_floor_variables.existing_harness_platform_key_ref

      IAC_PROVISIONER_TYPE : local.factory_floor_variables.provisioner_type
      IAC_PROVISIONER_VERSION : local.factory_floor_variables.provisioner_version

      WORKSPACE_ORG : var.organization_id
      WORKSPACE_PROJECT : var.project_id

      DOCKER_REGISTRY_ID : local.factory_floor_variables.hsf_pipeline_connector_ref
      HSF_IACM_WORKSPACE_MGR_IMAGE : local.factory_floor_variables.hsf_iacm_manager_plugin
      HSF_IDP_RESOURCE_MGR_IMAGE : local.factory_floor_variables.hsf_idp_resource_mgr_image
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (local.factory_floor_variables.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      USE_HARNESS_IDP : local.factory_floor_variables.should_use_harness_idp ? "true" : "skipped"
      HSF_CORE_MANAGER : local.hsf_core_mgr_workspace

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}

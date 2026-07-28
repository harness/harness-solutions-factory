locals {
  // Generate list of workspaces for unpacking (includes core manager only if IDP is not used)
  hsf_workspace_list = join(",", compact(flatten([
    ["${local.hsf_pilot_light_id}", "${local.hsf_solutions_factory_id}"],
    ["${var.should_use_harness_idp ? null : "${local.hsf_core_mgr_workspace}"}"]
  ])))
}

// Create pipeline to unpack Solutions Factory (only if enabled via variable)
resource "harness_platform_pipeline" "unpack_solutions_factory" {
  count       = var.should_unpack ? 1 : 0
  depends_on  = [time_sleep.core_resources]
  identifier  = "Unpack_Solutions_Factory"
  name        = "Unpack Solutions Factory"
  org_id      = harness_platform_organization.factories.id
  project_id  = harness_platform_project.solutions.id
  description = "Pipeline for unpacking Solutions Factory resources"
  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_Unpack_Solutions_Factory.yaml",
    {
      # Pipeline Setup Details
      PIPELINE_IDENTIFIER : "Unpack_Solutions_Factory"
      PIPELINE_NAME : "Unpack Solutions Factory"
      ORGANIZATION_ID : harness_platform_organization.factories.id
      PROJECT_ID : harness_platform_project.solutions.id
      DESCRIPTION : "Pipeline for unpacking Solutions Factory resources"
      HSF_PLATFORM_KEY : local.account_management_key
      HARNESS_K8s_CONNECTOR : var.kubernetes_connector
      IACM_STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/iacm_infrastructure.yaml",
        local.k8s_setup
      )
      IDP_STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/idp_infrastructure.yaml",
        local.k8s_setup
      )

      # Docker Image Registry Details
      DOCKER_REGISTRY_ID : local.hsf_pipeline_connector_ref
      HSF_SCRIPT_MGR_IMAGE : var.hsf_script_mgr_image
      HSF_IACM_MGR_IMAGE : var.hsf_iacm_manager_plugin
      HSF_IDP_MGR_IMAGE : var.hsf_idp_resource_mgr_image
      HSF_ROTATE_TOKEN_IMAGE : local.should_create_service_account ? var.hsf_rotate_token_plugin : "skipped"
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (var.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      USE_HARNESS_IDP : var.should_use_harness_idp ? "true" : "skipped"
      HSF_CORE_MANAGER : local.hsf_core_mgr_workspace
      HSF_WORKSPACE_LIST : local.hsf_workspace_list

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:hsf"]
  ])
}

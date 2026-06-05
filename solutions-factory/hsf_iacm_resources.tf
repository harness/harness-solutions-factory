// Factory Floor Module - IACM workspace management and pipeline orchestration
locals {
  hsf_core_mgr_workspace = "HSF_Core_Manager"
}

// Invoke the factory-floor module for IACM operations
module "factory_floor" {
  source = "../factory-floor"

  harness_platform_url     = var.harness_platform_url
  harness_platform_account = var.harness_platform_account

  organization_id                      = data.harness_platform_organization.selected.id
  project_id                           = data.harness_platform_project.selected.id
  should_create_hsf_core_mgr_workspace = false

  existing_harness_platform_key_ref   = var.existing_harness_platform_key_ref
  git_connector_ref                   = var.git_connector_ref
  git_repository_name                 = var.git_repository_name
  git_repository_branch               = var.git_repository_branch
  kubernetes_connector                = var.kubernetes_connector
  kubernetes_namespace                = var.kubernetes_namespace
  kubernetes_serviceaccount           = var.kubernetes_serviceaccount
  kubernetes_override_run_as_user     = var.kubernetes_override_run_as_user
  kubernetes_node_selectors           = var.kubernetes_node_selectors
  kubernetes_override_image_connector = var.kubernetes_override_image_connector
  kubernetes_override_image_name      = var.kubernetes_override_image_name
  provisioner_type                    = var.provisioner_type
  provisioner_version                 = var.provisioner_version
  hsf_pipeline_connector_ref          = var.hsf_pipeline_connector_ref
  hsf_script_mgr_image                = var.hsf_script_mgr_image
  hsf_idp_resource_mgr_image          = var.hsf_idp_resource_mgr_image
  hsf_iacm_manager_plugin             = var.hsf_iacm_manager_plugin
  should_use_harness_idp              = var.should_use_harness_idp
  hsf_plugin_ssl_verify_x509_strict   = var.hsf_plugin_ssl_verify_x509_strict
}

// Pipeline to deploy HSF Factory Floor to a project
// Only created when enable_hsf_mini_factory is true
resource "harness_platform_pipeline" "Deploy_Factory_Floor" {
  count       = var.enable_hsf_mini_factory ? 1 : 0
  identifier  = "Deploy_Factory_Floors"
  name        = "Deploy HSF Factory Floor to Project"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "Initialize HSF Factory Floor in a new or existing project"

  yaml = templatefile(
    "${path.module}/templates/pipelines/Deploy_Factory_Floor.yaml",
    {
      PIPELINE_IDENTIFIER : "Deploy_Factory_Floors"
      PIPELINE_NAME : "Deploy HSF Factory Floor to Project"
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "Initialize HSF Factory Floor in a new or existing project"

      KUBERNETES_IMAGE_NAME : var.kubernetes_override_image_name

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      IDP_STAGE_INFRASTRUCTURE : local.IDP_STAGE_INFRASTRUCTURE

      GIT_REPOSITORY_CONNECTOR : local.harness_solutions_factory_repo_connector
      GIT_REPOSITORY_NAME : local.harness_solutions_factory_repo
      GIT_REPOSITORY_SOURCE_TYPE : local.harness_solutions_factory_type
      GIT_REPOSITORY_BRANCH : local.harness_solutions_factory_key

      HTL_REPOSITORY_CONNECTOR : local.harness_template_library_repo_connector
      HTL_REPOSITORY_NAME : local.harness_template_library_repo_name
      HTL_REPOSITORY_TYPE : local.harness_template_library_type
      HTL_REPOSITORY_BRANCH : local.harness_template_library_key

      HARNESS_PLATFORM_API_KEY : var.existing_harness_platform_key_ref

      IAC_PROVISIONER_TYPE : var.provisioner_type
      IAC_PROVISIONER_VERSION : var.provisioner_version

      WORKSPACE_ORG : data.harness_platform_organization.selected.id
      WORKSPACE_PROJECT : data.harness_platform_project.selected.id

      DOCKER_REGISTRY_ID : var.hsf_pipeline_connector_ref
      HSF_IACM_WORKSPACE_MGR_IMAGE : var.hsf_iacm_manager_plugin
      HSF_IDP_RESOURCE_MGR_IMAGE : var.hsf_idp_resource_mgr_image
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (var.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      USE_HARNESS_IDP : var.should_use_harness_idp ? "true" : "skipped"
      HSF_CORE_MANAGER : local.hsf_core_mgr_workspace

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )

  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:hsf"]
  ])
}

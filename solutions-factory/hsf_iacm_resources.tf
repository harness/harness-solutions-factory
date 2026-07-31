// Factory Floor Module - IACM workspace management and pipeline orchestration
locals {
  hsf_core_mgr_workspace = "HSF_Core_Manager"

  solutions_factory_ws_defaults = flatten([{
    for elem in harness_platform_workspace.solutions_factory.terraform_variable :
    (elem.key) => (elem.value)
    }
  ])

  solutions_factory_defaults = length(local.solutions_factory_ws_defaults) > 0 ? local.solutions_factory_ws_defaults[0] : {}
}

// Invoke the factory-floor module for IACM operations
module "factory_floor" {
  depends_on = [harness_platform_workspace.solutions_factory]
  source     = "../factory-floor"

  harness_platform_url     = var.harness_platform_url
  harness_platform_account = var.harness_platform_account

  organization_id                      = var.organization_id
  project_id                           = var.project_id
  should_create_hsf_core_mgr_workspace = false
  should_use_primary_hsf_workspace     = false

  existing_harness_platform_key_ref   = local.solutions_factory_defaults.existing_harness_platform_key_ref
  git_connector_ref                   = local.solutions_factory_defaults.git_connector_ref
  git_repository_name                 = local.solutions_factory_defaults.git_repository_name
  git_repository_branch               = local.solutions_factory_defaults.git_repository_branch
  kubernetes_connector                = local.solutions_factory_defaults.kubernetes_connector
  kubernetes_namespace                = local.solutions_factory_defaults.kubernetes_namespace
  kubernetes_serviceaccount           = local.solutions_factory_defaults.kubernetes_serviceaccount
  kubernetes_override_run_as_user     = local.solutions_factory_defaults.kubernetes_override_run_as_user
  kubernetes_node_selectors           = jsondecode(local.solutions_factory_defaults.kubernetes_node_selectors)
  kubernetes_override_image_connector = local.solutions_factory_defaults.kubernetes_override_image_connector
  kubernetes_override_image_name      = local.solutions_factory_defaults.kubernetes_override_image_name
  provisioner_type                    = harness_platform_workspace.solutions_factory.provisioner_type
  provisioner_version                 = harness_platform_workspace.solutions_factory.provisioner_version
  hsf_pipeline_connector_ref          = local.solutions_factory_defaults.hsf_pipeline_connector_ref
  hsf_script_mgr_image                = local.solutions_factory_defaults.hsf_script_mgr_image
  hsf_idp_resource_mgr_image          = local.solutions_factory_defaults.hsf_idp_resource_mgr_image
  hsf_iacm_manager_plugin             = local.solutions_factory_defaults.hsf_iacm_manager_plugin
  hsf_rotate_token_plugin             = local.solutions_factory_defaults.hsf_rotate_token_plugin
  should_use_harness_idp              = local.solutions_factory_defaults.should_use_harness_idp
  hsf_plugin_ssl_verify_x509_strict   = local.solutions_factory_defaults.hsf_plugin_ssl_verify_x509_strict
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

      GIT_REPOSITORY_CONNECTOR : harness_platform_workspace.solutions_factory.repository_connector
      GIT_REPOSITORY_NAME : harness_platform_workspace.solutions_factory.repository
      GIT_REPOSITORY_SOURCE_TYPE : (
        harness_platform_workspace.solutions_factory.repository_commit != ""
        ?
        "tag"
        :
        harness_platform_workspace.solutions_factory.repository_sha != ""
        ?
        "sha"
        :
        "branch"
      )
      GIT_REPOSITORY_BRANCH : harness_platform_workspace.solutions_factory.repository_branch

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

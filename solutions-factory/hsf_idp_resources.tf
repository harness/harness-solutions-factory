// Pipeline to register custom IDP templates to Harness IDP
// Only created when should_use_harness_idp is true
resource "harness_platform_pipeline" "Register_IDP_Templates_Custom" {
  count       = var.should_use_harness_idp ? 1 : 0
  identifier  = "Register_Custom_IDP_Templates"
  name        = "Register Custom IDP Templates"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "Load and register custom HSF templates from the template library to Harness IDP"

  yaml = templatefile(
    "${path.module}/templates/pipelines/Register_IDP_Templates.yaml",
    {
      PIPELINE_IDENTIFIER : "Register_Custom_IDP_Templates"
      PIPELINE_NAME : "Register Custom IDP Templates"
      DESCRIPTION : "Load and register custom HSF templates from the template library to Harness IDP"
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      HARNESS_PLATFORM_KEY : var.existing_harness_platform_key_ref

      IDP_STAGE_INFRASTRUCTURE : local.IDP_STAGE_INFRASTRUCTURE

      HTL_REPOSITORY_CONNECTOR : local.harness_template_library_repo_connector
      HTL_REPOSITORY_NAME : local.harness_template_library_repo_name
      HTL_REPOSITORY_TYPE : local.harness_template_library_type
      HTL_REPOSITORY_BRANCH : local.harness_template_library_key

      DOCKER_REGISTRY_ID : var.hsf_pipeline_connector_ref
      HSF_IDP_RESOURCE_MGR_IMAGE : var.hsf_idp_resource_mgr_image
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (var.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "idp" }))
    }
  )

  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:idp"]
  ])
}

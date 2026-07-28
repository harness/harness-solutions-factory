
resource "harness_platform_pipeline" "Rotate_HSF_Token_generic" {
  identifier  = "Rotate_Harness_Service_Account_Token_and_Secret"
  name        = "Rotate Harness Service Account Token and Secret"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "This pipeline is capable of rotating a Harness Service Account token and updating a Harness Secret with that value."
  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_Rotate_HSF_Token.yaml",
    {
      PIPELINE_IDENTIFIER : "Rotate_Harness_Service_Account_Token_and_Secret"
      PIPELINE_NAME : "Rotate Harness Service Account Token and Secret"
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "This pipeline is capable of rotating a Harness Service Account token and updating a Harness Secret with that value."

      USE_HARNESS_IDP : local.factory_floor_variables.should_use_harness_idp ? "true" : "skipped"
      HSF_CORE_MANAGER : local.hsf_core_mgr_workspace

      DOCKER_REGISTRY_ID : local.factory_floor_variables.hsf_pipeline_connector_ref
      HSF_ROTATE_TOKEN_IMAGE : local.factory_floor_variables.hsf_rotate_token_plugin
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (local.factory_floor_variables.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")
      API_KEY_REF : local.factory_floor_variables.existing_harness_platform_key_ref

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      IDP_STAGE_INFRASTRUCTURE : local.IDP_STAGE_INFRASTRUCTURE

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )
  tags = flatten([
    for k, v in merge(local.common_tags, { pipeline_type : "hsf" }) : "${k}:${v}"
  ])
}

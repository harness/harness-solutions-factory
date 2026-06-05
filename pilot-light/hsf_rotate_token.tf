
// Create pipeline for automated HSF API token rotation
resource "harness_platform_pipeline" "Rotate_HSF_Token" {
  depends_on = [
    time_sleep.core_resources
  ]
  identifier  = "Rotate_HSF_Token"
  name        = "Rotate HSF Token"
  org_id      = harness_platform_organization.factories.id
  project_id  = harness_platform_project.solutions.id
  description = "Automatically rotate the HSF master service account API token"
  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_Rotate_HSF_Token.yaml",
    {
      PIPELINE_IDENTIFIER : "Rotate_HSF_Token"
      PIPELINE_NAME : "Rotate HSF Token"
      ORGANIZATION_ID : harness_platform_organization.factories.id
      PROJECT_ID : harness_platform_project.solutions.id
      DESCRIPTION : "Automatically rotate the HSF master service account API token"
      USE_HARNESS_IDP : var.should_use_harness_idp ? "true" : "skipped"
      HSF_CORE_MANAGER : local.hsf_core_mgr_workspace

      DOCKER_REGISTRY_ID : var.hsf_pipeline_connector_ref
      HSF_ROTATE_TOKEN_IMAGE : var.hsf_rotate_token_plugin
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (var.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")
      API_KEY_REF : local.account_management_key

      TOKEN_TYPE : "SERVICE_ACCOUNT"
      TOKEN_OWNER_REF : harness_platform_apikey.platform_manager.parent_id
      TOKEN_API_KEY_REF : harness_platform_apikey.platform_manager.id
      TOKEN_ORG_ID : ""
      TOKEN_PROJECT_ID : ""
      SECRET_ID : harness_platform_secret_text.harness_platform_key.id
      SECRET_ORG_ID : harness_platform_secret_text.harness_platform_key.org_id
      SECRET_PROJECT_ID : ""
      SHOULD_UPDATE_SELF : "true"

      IACM_STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/iacm_infrastructure.yaml",
        local.k8s_setup
      )
      IDP_STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/idp_infrastructure.yaml",
        local.k8s_setup
      )

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:hsf"]
  ])
}

resource "harness_platform_triggers" "Rotate_HSF_Token" {
  count      = var.should_rotate_on_schedule ? 1 : 0
  identifier = "Scheduled_Rotation"
  name       = "Scheduled Rotation"
  org_id     = harness_platform_organization.factories.id
  project_id = harness_platform_project.solutions.id
  target_id  = harness_platform_pipeline.Rotate_HSF_Token.id
  yaml       = <<-EOT
  trigger:
    name: Scheduled Rotation
    identifier: Scheduled_Rotation
    stagesToExecute: []
    enabled: true
    description: Automatically Rotate Token
    tags:
      ${indent(4, yamlencode(local.common_tags))}
    orgIdentifier: ${harness_platform_organization.factories.id}
    projectIdentifier: ${harness_platform_project.solutions.id}
    pipelineIdentifier: ${harness_platform_pipeline.Rotate_HSF_Token.id}
    source:
      type: Scheduled
      spec:
        type: Cron
        spec:
          type: UNIX
          expression: ${var.rotation_schedule}

    EOT
  tags       = local.common_tags_tuple
}

resource "harness_platform_pipeline" "Rotate_HSF_Token_generic" {
  depends_on = [
    time_sleep.core_resources
  ]
  identifier  = "Rotate_Harness_Service_Account_Token_and_Secret"
  name        = "Rotate Harness Service Account Token and Secret"
  org_id      = harness_platform_organization.factories.id
  project_id  = harness_platform_project.solutions.id
  description = "This pipeline is capable of rotating a Harness Service Account token and updating a Harness Secret with that value."
  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_Rotate_HSF_Token.yaml",
    {
      PIPELINE_IDENTIFIER : "Rotate_Harness_Service_Account_Token_and_Secret"
      PIPELINE_NAME : "Rotate Harness Service Account Token and Secret"
      ORGANIZATION_ID : harness_platform_organization.factories.id
      PROJECT_ID : harness_platform_project.solutions.id
      DESCRIPTION : "This pipeline is capable of rotating a Harness Service Account token and updating a Harness Secret with that value."
      USE_HARNESS_IDP : var.should_use_harness_idp ? "true" : "skipped"
      HSF_CORE_MANAGER : local.hsf_core_mgr_workspace

      DOCKER_REGISTRY_ID : var.hsf_pipeline_connector_ref
      HSF_ROTATE_TOKEN_IMAGE : var.hsf_rotate_token_plugin
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (var.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")
      API_KEY_REF : local.account_management_key

      TOKEN_TYPE : "<+input>.default(SERVICE_ACCOUNT).selectOneFrom(SERVICE_ACCOUNT,USER)"
      TOKEN_OWNER_REF : "<+input>"
      TOKEN_API_KEY_REF : "<+input>"
      TOKEN_ORG_ID : "<+input>"
      TOKEN_PROJECT_ID : "<+input>"
      SECRET_ID : "<+input>"
      SECRET_ORG_ID : "<+input>"
      SECRET_PROJECT_ID : "<+input>"
      SHOULD_UPDATE_SELF : "<+input>.default(false).selectOneFrom(true, false)"

      IACM_STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/iacm_infrastructure.yaml",
        local.k8s_setup
      )
      IDP_STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/idp_infrastructure.yaml",
        local.k8s_setup
      )

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:hsf"]
  ])
}

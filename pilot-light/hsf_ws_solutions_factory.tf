locals {
  // Solutions Factory workspace identifier
  hsf_solutions_factory_id = "harness_solutions_factory"
}

// Create Solutions Factory workspace for IACM resource management and deployments
resource "harness_platform_workspace" "solutions_factory" {
  lifecycle {
    ignore_changes = all
  }
  depends_on          = [harness_platform_connector_docker.hsf]
  name                = "Harness Solutions Factory"
  identifier          = local.hsf_solutions_factory_id
  org_id              = harness_platform_organization.factories.id
  project_id          = harness_platform_project.solutions.id
  provisioner_type    = var.provisioner_type
  provisioner_version = var.provisioner_version

  // Use Solutions Factory repository connector (customer can override after deployment)
  repository_connector = local.harness_solutions_factory_repo_connector
  repository           = local.harness_solutions_factory_repo
  repository_branch    = local.harness_solutions_factory_repo_branch
  repository_commit    = local.harness_solutions_factory_repo_tag
  repository_sha       = local.harness_solutions_factory_repo_sha
  #
  repository_path         = "solutions-factory"
  cost_estimation_enabled = false
  tags                    = ["source:hsf_system", "type:solutions_factory"]

  terraform_variable {
    key        = "git_connector_ref"
    value      = local.harness_template_library_repo_connector
    value_type = "string"
  }

  terraform_variable {
    key        = "git_repository_name"
    value      = local.harness_template_library_repo
    value_type = "string"
  }

  terraform_variable {
    key        = "git_repository_fetch_type"
    value      = local.harness_template_library_fetch_type
    value_type = "string"
  }

  terraform_variable {
    key        = "git_repository_branch"
    value      = local.harness_template_library_fetch_key
    value_type = "string"
  }

  terraform_variable {
    key        = "existing_harness_platform_key_ref"
    value      = local.account_management_key
    value_type = "string"
  }

  dynamic "terraform_variable" {
    for_each = local.use_k8s

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }

  dynamic "terraform_variable" {
    for_each = local.use_custom_image

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }
  dynamic "terraform_variable" {
    for_each = local.use_custom_image_connector

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }

  dynamic "terraform_variable" {
    for_each = local.hsf_plugin_workspace_variables

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }

  terraform_variable {
    key        = "enable_hsf_mini_factory"
    value      = false
    value_type = "string"
  }

  terraform_variable {
    key        = "should_use_harness_idp"
    value      = var.should_use_harness_idp
    value_type = "string"
  }

  terraform_variable {
    key        = "should_use_hsf_hub"
    value      = false
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_ENDPOINT"
    value      = var.harness_platform_url
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_ACCOUNT_ID"
    value      = var.harness_platform_account
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_PLATFORM_API_KEY"
    value      = local.account_management_key
    value_type = "secret"
  }

  environment_variable {
    key        = "TF_VAR_harness_platform_url"
    value      = var.harness_platform_url
    value_type = "string"
  }

  environment_variable {
    key        = "TF_VAR_harness_platform_account"
    value      = var.harness_platform_account
    value_type = "string"
  }

  environment_variable {
    key        = "PLUGIN_HSF_ENABLED"
    value      = true
    value_type = "string"
  }

  default_pipelines = {
    "destroy" = harness_platform_pipeline.pipeline.id
    "drift"   = harness_platform_pipeline.pipeline.id
    "plan"    = harness_platform_pipeline.pipeline.id
    "apply"   = harness_platform_pipeline.pipeline.id
  }

}

resource "harness_platform_pipeline" "pipeline" {
  identifier  = "Deploy_Solutions_Factory"
  name        = "Deploy Solutions Factory"
  org_id      = harness_platform_organization.factories.id
  project_id  = harness_platform_project.solutions.id
  description = "Pipeline used to manage the HSF Solutions-Factory workspace. Used during upgrades and configuration changes"

  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_Deploy_Solutions_Factory.yaml",
    {
      PIPELINE_IDENTIFIER : "Deploy_Solutions_Factory"
      PIPELINE_NAME : "Deploy Solutions Factory"
      ORGANIZATION_ID : harness_platform_organization.factories.id
      PROJECT_ID : harness_platform_project.solutions.id
      DESCRIPTION : "Pipeline used to manage the HSF Solutions-Factory workspace. Used during upgrades and configuration changes"
      WORKSPACE_NAME : local.hsf_solutions_factory_id
      KUBERNETES_IMAGE_NAME : var.kubernetes_override_image_name
      STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/iacm_infrastructure.yaml",
        local.k8s_setup
      )
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (var.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:hsf"]
  ])
}

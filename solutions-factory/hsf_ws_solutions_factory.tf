// Note: This configuration forces that the pilot-light must be run before this template
//
// Import the previously deployed workspace
import {
  to = harness_platform_workspace.solutions_factory
  id = join("/", [
    data.harness_platform_organization.selected.id,
    data.harness_platform_project.selected.id,
    local.hsf_solutions_factory_id,
  ])
}

locals {
  // Solutions Factory workspace identifier
  hsf_solutions_factory_id = "harness_solutions_factory"
}

// Create Solutions Factory workspace for IACM resource management and deployments
resource "harness_platform_workspace" "solutions_factory" {
  lifecycle {
    ignore_changes = [
      provisioner_type,
      provisioner_version,
      repository_connector,
      repository,
      repository_branch,
      repository_commit,
      repository_sha,
      default_pipelines
    ]
  }
  name                = "Harness Solutions Factory"
  identifier          = local.hsf_solutions_factory_id
  org_id              = data.harness_platform_organization.selected.id
  project_id          = data.harness_platform_project.selected.id
  provisioner_type    = "skipped"
  provisioner_version = "skipped"

  // Use Solutions Factory repository connector (customer can override after deployment)
  repository_connector = "skipped" # data.harness_platform_workspace.pilot_light.repository_connector
  repository           = "skipped"
  repository_branch    = "skipped"
  #
  repository_path         = "solutions-factory"
  cost_estimation_enabled = false
  tags                    = ["source:hsf_system", "type:solutions_factory"]

  terraform_variable {
    key        = "existing_harness_platform_key_ref"
    value      = var.existing_harness_platform_key_ref
    value_type = "string"
  }

  terraform_variable {
    key        = "git_connector_ref"
    value      = local.harness_template_library_repo_connector
    value_type = "string"
  }

  terraform_variable {
    key        = "git_repository_name"
    value      = local.harness_template_library_repo_name
    value_type = "string"
  }

  terraform_variable {
    key        = "git_repository_fetch_type"
    value      = local.harness_template_library_type
    value_type = "string"
  }

  terraform_variable {
    key        = "git_repository_branch"
    value      = local.harness_template_library_key
    value_type = "string"
  }

  terraform_variable {
    key        = "kubernetes_connector"
    value      = var.kubernetes_connector
    value_type = "string"
  }

  terraform_variable {
    key        = "kubernetes_namespace"
    value      = var.kubernetes_namespace
    value_type = "string"
  }

  terraform_variable {
    key        = "kubernetes_serviceaccount"
    value      = var.kubernetes_serviceaccount
    value_type = "string"
  }

  terraform_variable {
    key        = "kubernetes_override_run_as_user"
    value      = var.kubernetes_override_run_as_user
    value_type = "string"
  }

  terraform_variable {
    key        = "kubernetes_node_selectors"
    value      = jsonencode(var.kubernetes_node_selectors)
    value_type = "string"
  }

  terraform_variable {
    key        = "kubernetes_override_image_connector"
    value      = var.kubernetes_override_image_connector
    value_type = "string"
  }

  terraform_variable {
    key        = "kubernetes_override_image_name"
    value      = var.kubernetes_override_image_name
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_pipeline_connector_ref"
    value      = var.hsf_pipeline_connector_ref
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_script_mgr_image"
    value      = var.hsf_script_mgr_image
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_idp_resource_mgr_image"
    value      = var.hsf_idp_resource_mgr_image
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_iacm_manager_plugin"
    value      = var.hsf_iacm_manager_plugin
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_rotate_token_plugin"
    value      = var.hsf_rotate_token_plugin
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_plugin_ssl_verify_x509_strict"
    value      = var.hsf_plugin_ssl_verify_x509_strict
    value_type = "string"
  }

  terraform_variable {
    key        = "enable_hsf_mini_factory"
    value      = var.enable_hsf_mini_factory
    value_type = "string"
  }

  terraform_variable {
    key        = "should_use_harness_idp"
    value      = var.should_use_harness_idp
    value_type = "string"
  }

  terraform_variable {
    key        = "should_use_hsf_hub"
    value      = var.should_use_hsf_hub
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
    value      = var.existing_harness_platform_key_ref
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

}

locals {
  hsf_hub_mgr_id = "HSF_Hub_Manager"
}

// HSF Hub Manager workspace for centralized workspace management
// This workspace is only created when var.should_use_hsf_hub is true
resource "harness_platform_workspace" "hsf_hub_mgr" {
  count      = var.should_use_hsf_hub ? 1 : 0
  depends_on = [harness_platform_pipeline.hsf_hub_mgr]

  lifecycle {
    // Allow manual updates to provisioner and repository settings
    // These parameters can be modified outside of Terraform for user customization
    ignore_changes = [
      provisioner_type,
      provisioner_version,
      provider_connector,
      repository_connector,
      repository_branch,
      repository
    ]
  }

  name                = replace(local.hsf_hub_mgr_id, "_", " ")
  identifier          = local.hsf_hub_mgr_id
  org_id              = data.harness_platform_organization.selected.id
  project_id          = data.harness_platform_project.selected.id
  provisioner_type    = harness_platform_workspace.solutions_factory.provisioner_type
  provisioner_version = harness_platform_workspace.solutions_factory.provisioner_version

  repository_connector = harness_platform_workspace.solutions_factory.repository_connector
  repository           = harness_platform_workspace.solutions_factory.repository
  repository_branch    = harness_platform_workspace.solutions_factory.repository_branch != "" ? harness_platform_workspace.solutions_factory.repository_branch : null
  repository_commit    = harness_platform_workspace.solutions_factory.repository_commit != "" ? harness_platform_workspace.solutions_factory.repository_commit : null
  repository_sha       = harness_platform_workspace.solutions_factory.repository_sha != "" ? harness_platform_workspace.solutions_factory.repository_sha : null
  repository_path      = "hsf-hub"

  cost_estimation_enabled = false
  tags                    = ["source:hsf_system", "type:hsf-hub"]

  // Template library configuration
  terraform_variable {
    key        = "content_library_connector"
    value      = "<+variable.account.custom_template_library_connector>"
    value_type = "string"
  }

  terraform_variable {
    key        = "content_library_repo"
    value      = "<+variable.account.custom_template_library_repo>"
    value_type = "string"
  }

  terraform_variable {
    key        = "content_library_branch"
    value      = "main"
    value_type = "string"
  }

  terraform_variable {
    key        = "content_library"
    value      = "/harness/content-library"
    value_type = "string"
  }

  terraform_variable {
    key        = "registration_mgr"
    value      = "hub_registration_mgr.yaml"
    value_type = "string"
  }

  // Harness platform credentials and configuration
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
    key        = "TF_VAR_harness_platform_key"
    value      = var.existing_harness_platform_key_ref
    value_type = "secret"
  }

  environment_variable {
    key        = "PLUGIN_HSF_ENABLED"
    value      = "true"
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_ACCOUNT_ID"
    value      = var.harness_platform_account
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_ENDPOINT"
    value      = var.harness_platform_url
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_PLATFORM_API_KEY"
    value      = var.existing_harness_platform_key_ref
    value_type = "secret"
  }

  default_pipelines = {
    "destroy" = harness_platform_pipeline.hsf_hub_mgr.0.id
    "drift"   = harness_platform_pipeline.hsf_hub_mgr.0.id
    "plan"    = harness_platform_pipeline.hsf_hub_mgr.0.id
    "apply"   = harness_platform_pipeline.hsf_hub_mgr.0.id
  }
}

// Pipeline for managing HSF Hub workspace deployment and configuration
resource "harness_platform_pipeline" "hsf_hub_mgr" {
  count       = var.should_use_hsf_hub ? 1 : 0
  identifier  = "Deploy_HSF_Hub"
  name        = "Deploy HSF Hub"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "Pipeline for HSF Hub workspace management, upgrades, and configuration changes"

  yaml = templatefile(
    "${path.module}/templates/pipelines/Deploy_HSF_Hub.yaml",
    {
      PIPELINE_IDENTIFIER : "Deploy_HSF_Hub"
      PIPELINE_NAME : "Deploy HSF Hub"
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "Pipeline for HSF Hub workspace management, upgrades, and configuration changes"
      WORKSPACE_NAME : local.hsf_hub_mgr_id
      KUBERNETES_IMAGE_NAME : var.kubernetes_override_image_name
      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      HSF_PLUGIN_SSL_VERIFY_X509_STRICT : (var.hsf_plugin_ssl_verify_x509_strict ? "true" : "false")

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:hsf"]
  ])
}


locals {
  // HSF Core Manager workspace identifier
  hsf_core_mgr_workspace = "HSF_Core_Manager"
}

// Create placeholder HSF Core Manager workspace (only when Harness IDP is not used)
resource "harness_platform_workspace" "hsf_core_mgr" {
  count = var.should_use_harness_idp ? 0 : 1
  depends_on = [
    time_sleep.core_resources
  ]
  lifecycle {
    ignore_changes = [
      provisioner_type,
      provisioner_version,
      repository_connector,
      repository_branch,
      repository
    ]
  }
  name                = replace(local.hsf_core_mgr_workspace, "_", " ")
  identifier          = local.hsf_core_mgr_workspace
  description         = <<-EOF
    Placeholder workspace for system stage executions when Harness IDP is not used.
    Do not modify resources or configuration directly on this workspace.
  EOF
  org_id              = harness_platform_organization.factories.id
  project_id          = harness_platform_project.solutions.id
  provisioner_type    = var.provisioner_type
  provisioner_version = var.provisioner_version

  # In this case, we will always set the original source for the HSF Pilot Light to the Official
  # repository. Since the lifecycle changes for these three parameters will be ignored, the customer
  # will be able to adjust to their needs.
  repository_connector = local.harness_solutions_factory_repo_connector
  repository           = local.harness_solutions_factory_repo
  repository_branch    = local.harness_solutions_factory_repo_branch
  repository_commit    = local.harness_solutions_factory_repo_tag
  repository_sha       = local.harness_solutions_factory_repo_sha
  #
  repository_path         = "hsf-core-mgr"
  cost_estimation_enabled = false
  tags                    = ["source:hsf_system", "type:hsf-core-mgr"]

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
    value      = local.account_management_key
    value_type = "secret"
  }

  environment_variable {
    key        = "PLUGIN_HSF_ENABLED"
    value      = "true"
    value_type = "string"
  }

}

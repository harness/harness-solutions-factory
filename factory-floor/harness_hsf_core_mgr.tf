// HSF Core Manager workspace for centralized resource management (when IDP disabled)

// Workspace identifier for core management operations
locals {
  hsf_core_mgr_workspace = "HSF_Core_Manager"
}

// Create Core Manager workspace when IDP integration is disabled
resource "harness_platform_workspace" "hsf_core_mgr" {
  // Only create workspace when IDP is disabled and core manager is requested
  count = (
    local.factory_floor_variables.should_use_harness_idp && local.factory_floor_variables.should_use_harness_idp != null
    ? 0
    : var.should_create_hsf_core_mgr_workspace
    ? 1
    : 0
  )

  name        = replace(local.hsf_core_mgr_workspace, "_", " ")
  identifier  = local.hsf_core_mgr_workspace
  description = <<-EOF
    Note: This Workspace is used as a placeholder for system stage executions when Harness IDP is not leveraged.
    No resource or configuration changes should be made directly to this workspace.
  EOF

  org_id              = var.organization_id
  project_id          = var.project_id
  provisioner_type    = local.factory_floor_variables.provisioner_type
  provisioner_version = local.factory_floor_variables.provisioner_version

  // Default HSF repository settings (customer-adjustable via lifecycle ignores)
  repository_connector = local.factory_floor_variables.git_connector_ref
  repository           = local.factory_floor_variables.git_repository_name
  repository_branch    = local.factory_floor_variables.git_repository_branch
  repository_path      = "hsf-core-mgr"

  cost_estimation_enabled = false
  tags                    = ["source:hsf_system", "type:hsf-core-mgr"]

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
    value      = local.factory_floor_variables.existing_harness_platform_key_ref
    value_type = "secret"
  }

  environment_variable {
    key        = "PLUGIN_HSF_ENABLED"
    value      = true
    value_type = "string"
  }

  // Validate all required factory floor variables before creating workspace
  lifecycle {
    precondition {
      condition     = length(local.invalid_factory_floor_variables) == 0
      error_message = "Null values found for keys: ${join(", ", local.invalid_factory_floor_variables)}"
    }
    // Allow manual updates to provisioner and repository settings post-deployment
    ignore_changes = [
      provisioner_type,
      provisioner_version,
      repository_connector,
      repository_branch,
      repository
    ]
  }
}

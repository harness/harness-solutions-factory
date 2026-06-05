// Create custom template library repository (only if enabled via variable)
resource "harness_platform_repo" "custom_tpl" {
  count          = var.should_setup_custom_tpl ? 1 : 0
  identifier     = "custom-harness-template-library"
  org_id         = harness_platform_organization.factories.id
  description    = "Custom Harness Template Library repository for Solutions Factory"
  default_branch = "main"

  source {
    repo = "harness-solutions-factory/custom-harness-template-library"
    type = "github"
  }
}

// Create Git connector for custom template library repository
resource "harness_platform_connector_git" "custom_tpl" {
  count       = var.should_setup_custom_tpl ? 1 : 0
  identifier  = "custom_template_library_connector"
  name        = "Custom Template Library Connector"
  org_id      = harness_platform_organization.factories.id
  description = "Connector for custom Harness Template Library repository"
  tags = flatten([
    ["required_for:iacm_workspaces"],
    local.common_tags_tuple
  ])

  url             = harness_platform_repo.custom_tpl.0.git_url
  connection_type = "Repo"
  credentials {
    http {
      username     = "harness"
      password_ref = local.account_management_key
    }
  }
}

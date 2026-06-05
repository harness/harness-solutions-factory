// Official Harness Solutions Factory Git Connector (created only if custom connector not provided)
resource "harness_platform_connector_git" "hsf_official" {
  count = var.hsf_source_connector == "skipped" ? 1 : 0
  lifecycle {
    ignore_changes = [credentials]
  }
  identifier  = "Harness_Solutions_Factory_Repo___Official"
  name        = "Harness Solutions Factory Repo - Official"
  org_id      = harness_platform_organization.factories.id
  description = "Managed by Harness Solutions Factory"
  tags = flatten([
    local.common_tags_tuple,
    ["required_for:iacm_workspaces"],
  ])

  url             = "https://github.com/harness-solutions-factory"
  validation_repo = "harness-solutions-factory"
  connection_type = "Account"
  credentials {
    http {
      username = "harness"
      // Despite public repository, connector requires credentials for auth (use master HSF Secret)
      password_ref = local.account_management_key
    }
  }
}

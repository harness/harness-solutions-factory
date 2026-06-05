// Organization-level variables for Solutions Factory operations

// Harness Platform endpoint variable for API interactions
resource "harness_platform_variables" "HARNESS_ENDPOINT" {
  identifier = "HARNESS_ENDPOINT"
  name       = "HARNESS_ENDPOINT"
  org_id     = data.harness_platform_organization.selected.id
  type       = "String"
  spec {
    value_type  = "FIXED"
    fixed_value = var.harness_platform_url
  }
}

// Portal resources endpoint for IACM API calls (requires WORKSPACE_ORG and WORKSPACE_PROJECT pipeline variables)
resource "harness_platform_variables" "HARNESS_PORTAL_RESOURCES" {
  identifier  = "HARNESS_PORTAL_RESOURCES"
  name        = "HARNESS_PORTAL_RESOURCES"
  org_id      = data.harness_platform_organization.selected.id
  description = "IACM portal API endpoint. Requires pipeline variables: WORKSPACE_ORG and WORKSPACE_PROJECT"
  type        = "String"
  spec {
    value_type  = "FIXED"
    fixed_value = "iacm/api/orgs/<+pipeline.variables.WORKSPACE_ORG>/projects/<+pipeline.variables.WORKSPACE_PROJECT>/workspaces"
  }
}

// Mini-Factory feature flag
resource "harness_platform_variables" "enable_hsf_mini_factory" {
  depends_on  = [data.harness_platform_project.selected]
  identifier  = "enable_hsf_mini_factory"
  name        = "Should HSF Mini-Factory configuration be leveraged"
  type        = "String"
  org_id      = data.harness_platform_organization.selected.id
  description = "Enable mini-factory distribution for IDP workflows"
  spec {
    value_type  = "FIXED"
    fixed_value = var.enable_hsf_mini_factory
  }
}

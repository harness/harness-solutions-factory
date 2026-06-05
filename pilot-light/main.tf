// Create Harness Platform Management organization for HSF foundation
resource "harness_platform_organization" "factories" {
  identifier  = "Harness_Platform_Management"
  name        = "Harness Platform Management - HSF"
  description = "Centralized Harness Platform Management"
  tags        = local.common_tags_tuple
}

// Create Solutions Factory project for workspace and resource management
resource "harness_platform_project" "solutions" {
  identifier = "Solutions_Factory"
  name       = "Solutions Factory"
  org_id     = harness_platform_organization.factories.id
  color      = "#73dfe7"
  tags       = local.common_tags_tuple
}

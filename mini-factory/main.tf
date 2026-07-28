// Fetch the selected Harness organization
data "harness_platform_organization" "selected" {
  identifier = var.organization_id
}

// Create Mini-Factory project in the organization
resource "harness_platform_project" "selected" {
  identifier = var.project_id
  name       = replace(var.project_id, "_", " ")
  org_id     = data.harness_platform_organization.selected.id
  color      = "#73dfe7"
  tags       = local.common_tags_tuple
}

// Deploy Factory Floor module into Mini-Factory project
module "factory_floor" {
  source = "../factory-floor"

  harness_platform_url     = var.harness_platform_url
  harness_platform_account = var.harness_platform_account

  organization_id = data.harness_platform_organization.selected.id
  project_id      = harness_platform_project.selected.id
}

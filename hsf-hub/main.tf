// Fetch the selected Harness organization
data "harness_platform_organization" "selected" {
  identifier = var.organization_id
}

// Create HSF Hub project with distinctive color
resource "harness_platform_project" "selected" {
  identifier  = local.fmt_identifier
  name        = var.project_name
  org_id      = data.harness_platform_organization.selected.id
  description = var.project_description
  color       = "#9dbff9"

  tags = local.common_tags_tuple
}

// Wait for project resources to fully initialize (avoids race condition)
resource "time_sleep" "project_setup" {
  depends_on = [
    harness_platform_project.selected
  ]

  create_duration = "15s"
}

// Fetch project details after initialization
data "harness_platform_project" "selected" {
  depends_on = [time_sleep.project_setup]
  identifier = harness_platform_project.selected.id
  org_id     = data.harness_platform_organization.selected.id
}

// Fetch current account permissions (for auth context)
data "harness_platform_permissions" "current" {}

// Fetch Solutions Factory defaults workspace configuration
data "harness_platform_workspace" "solutions_factory" {
  identifier = "harness_solutions_factory"
  org_id     = "Harness_Platform_Management"
  project_id = "Solutions_Factory"
}

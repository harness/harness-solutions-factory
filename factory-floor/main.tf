// Fetch the selected Harness organization
data "harness_platform_organization" "selected" {
  identifier = var.organization_id
}

// Fetch the selected Harness project
data "harness_platform_project" "selected" {
  identifier = var.project_id
  org_id     = var.organization_id
}

// Fetch the primary Solutions Factory workspace for default configurations
data "harness_platform_workspace" "solutions_factory" {
  identifier = "harness_solutions_factory"
  org_id     = "Harness_Platform_Management"
  project_id = "Solutions_Factory"
}

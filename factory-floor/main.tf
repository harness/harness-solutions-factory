// When enabled, this will load the default from the
// primary Solutions Factory workspace to return default
// configurations and variables.
//
data "harness_platform_workspace" "solutions_factory" {
  count      = var.should_use_primary_hsf_workspace ? 1 : 0
  identifier = "harness_solutions_factory"
  org_id     = "Harness_Platform_Management"
  project_id = "Solutions_Factory"
}

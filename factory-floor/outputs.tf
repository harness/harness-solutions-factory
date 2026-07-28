// Pipeline identifiers for factory-floor operations

// Bulk workspace management pipeline ID
output "bulk_management_pipeline_id" {
  description = "Pipeline for bulk workspace management operations"
  value       = "${local.tier_handler}${harness_platform_pipeline.Bulk_Workspace_Management.id}"
}

// Create and manage workspaces pipeline ID
output "create_manage_pipeline_id" {
  description = "Pipeline for creating and managing IACM workspaces"
  value       = "${local.tier_handler}${harness_platform_pipeline.Create_and_Manage_IACM_Workspace.id}"
}

// Drift analysis pipeline ID
output "drift_analysis_pipeline_id" {
  description = "Pipeline for analyzing infrastructure drift"
  value       = "${local.tier_handler}${harness_platform_pipeline.Execute_Drift_Analysis.id}"
}

// Plan and validate pipeline ID
output "plan_validate_pipeline_id" {
  description = "Pipeline for planning and validating infrastructure changes"
  value       = "${local.tier_handler}${harness_platform_pipeline.Plan_and_Validate_IACM_Workspace.id}"
}

// Provision workspaces pipeline ID
output "provision_workspace_pipeline_id" {
  description = "Pipeline for provisioning infrastructure in IACM workspaces"
  value       = "${local.tier_handler}${harness_platform_pipeline.Provision_IACM_Workspace.id}"
}

// Teardown workspaces pipeline ID
output "teardown_workspace_pipeline_id" {
  description = "Pipeline for tearing down infrastructure and workspaces"
  value       = "${local.tier_handler}${harness_platform_pipeline.Teardown_IACM_Workspace.id}"
}

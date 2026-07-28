// Pipeline identifiers for factory-floor operations

// Bulk workspace management pipeline ID
output "bulk_management_pipeline_id" {
  description = "Pipeline for bulk workspace management operations"
  value       = module.factory_floor.bulk_management_pipeline_id
}

// Create and manage workspaces pipeline ID
output "create_manage_pipeline_id" {
  description = "Pipeline for creating and managing IACM workspaces"
  value       = module.factory_floor.create_manage_pipeline_id
}

// Drift analysis pipeline ID
output "drift_analysis_pipeline_id" {
  description = "Pipeline for analyzing infrastructure drift"
  value       = module.factory_floor.drift_analysis_pipeline_id
}

// Plan and validate pipeline ID
output "plan_validate_pipeline_id" {
  description = "Pipeline for planning and validating infrastructure changes"
  value       = module.factory_floor.plan_validate_pipeline_id
}

// Provision workspaces pipeline ID
output "provision_workspace_pipeline_id" {
  description = "Pipeline for provisioning infrastructure in IACM workspaces"
  value       = module.factory_floor.provision_workspace_pipeline_id
}

// Teardown workspaces pipeline ID
output "teardown_workspace_pipeline_id" {
  description = "Pipeline for tearing down infrastructure and workspaces"
  value       = module.factory_floor.teardown_workspace_pipeline_id
}

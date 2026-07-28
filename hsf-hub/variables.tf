// Harness Account Setup
variable "harness_platform_url" {
  type        = string
  description = "Harness Platform URL (defaults to Harness SaaS)"
  default     = "https://app.harness.io/gateway"
}

variable "harness_platform_account" {
  type        = string
  description = "Harness Platform Account Number (falls back to HARNESS_ACCOUNT_ID env var)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to associate with resources"
  default     = {}
}

// HSF Hub Project Configuration
variable "organization_id" {
  type        = string
  description = "Harness organization ID (must exist before execution)"
  default     = "Harness_Platform_Management"
}

variable "project_id" {
  type        = string
  description = "HSF Hub project identifier (auto-formatted from project_name if not provided)"
  default     = null
}

variable "project_name" {
  type        = string
  description = "HSF Hub project display name"
  default     = "HSF Hub"
}

variable "project_description" {
  type        = string
  description = "HSF Hub project description"
  default     = "Central Hub for Harness Solutions Factory"
}

// Content Library Configuration
// Note: This variable is not leveraged in the Terraform code but is used by the deployment pipeline
// and therefore, we have added the variable to enable configuring the value in the workspace configuration.
variable "content_library_connector" {
  type        = string
  description = "SCM connector for content library (required by deployment pipelines)"
  default     = null
}

// Note: This variable is not leveraged in the Terraform code but is used by the deployment pipeline
// and therefore, we have added the variable to enable configuring the value in the workspace configuration.
variable "content_library_repo" {
  type        = string
  description = "Repository containing content library (required by deployment pipelines)"
  default     = null
}

variable "content_library_branch" {
  type        = string
  description = "Branch/tag/SHA for content library source"
  default     = "main"
}

variable "content_library" {
  type        = string
  description = "Absolute path to content library root directory. This path should exist and contain a local copy of your Harness Template Library."
  default     = "/harness/content-library"
}

variable "registration_mgr" {
  type        = string
  description = "Registration manager YAML file name in content library"
  default     = "hub_registration_mgr.yaml"
}

// Workspace Management Configuration
variable "workspace_mgmt_organization_id" {
  type        = string
  description = "Organization ID for workspace deployments (must exist before execution)"
  default     = "Harness_Platform_Management"
}

variable "workspace_mgmt_project_id" {
  type        = string
  description = "Project ID for workspace deployments (must exist before execution)"
  default     = "Solutions_Factory"
}

variable "workspace_mgmt_pipeline_id" {
  type        = string
  description = "Pipeline ID for executing workspace management tasks"
  default     = "Create_and_Manage_IACM_Workspaces"
}

// Harness Account Setup
variable "harness_platform_url" {
  type        = string
  description = "The Harness Platform URL (defaults to Harness SaaS)"
  default     = "https://app.harness.io/gateway"
}

variable "harness_platform_account" {
  type        = string
  description = "The Harness Platform Account Number (falls back to HARNESS_ACCOUNT_ID env var)"
  default     = null
}

variable "organization_id" {
  type        = string
  description = "The Harness organization ID (must exist before execution)"
  default     = "Harness_Platform_Management"
}

variable "project_id" {
  type        = string
  description = "The Harness project ID for Solutions Factory"
  default     = "Solutions_Factory"
}

// SCM Source Configurations and Settings
variable "hsf_source_connector" {
  type        = string
  description = "Existing Harness SCM connector reference. Use 'skipped' for the default official repositories connector. Prefix account/org connectors with 'account.' or 'org.' as needed"
  default     = "skipped"
}

variable "hsf_source_repository" {
  type        = string
  description = "SCM repository for IACM workspaces (defaults to official Harness Solutions Factory repository)"
  default     = "harness-solutions-factory"
}

variable "hsf_source_fetch_type" {
  type        = string
  description = "SCM fetch type: 'branch', 'tag', or 'sha'"
  default     = "tag"

  validation {
    condition     = contains(["branch", "tag", "sha"], lower(var.hsf_source_fetch_type))
    error_message = "SCM Fetch Type must be one of: branch, tag, or sha. Must match the type of hsf_source_branch."
  }
}

variable "hsf_source_branch" {
  type        = string
  description = "SCM source reference (branch name, tag, or commit SHA) for IACM workspaces"
  default     = "v2.5.0"
}


variable "existing_harness_platform_key_ref" {
  type        = string
  description = "Reference to existing Harness Platform API key (secret reference)"
}

// Harness Template Library Source Code Manager configuration
variable "git_connector_ref" {
  type        = string
  description = "Git connector reference for template library deployment. Use 'skipped' to default to account variable custom_template_library_connector"
  default     = "skipped"
}

variable "git_repository_name" {
  type        = string
  description = "Git repository name for template library. Use 'skipped' to default to account variable custom_template_library_repo"
  default     = "skipped"
}

variable "git_repository_fetch_type" {
  type        = string
  description = "Git fetch type: 'branch', 'tag', 'sha', or 'skipped' (uses account default)"
  default     = "skipped"

  validation {
    condition     = contains(["branch", "tag", "sha", "skipped"], lower(var.git_repository_fetch_type))
    error_message = "Git fetch type must be one of: branch, tag, sha, or skipped. Must match the type of git_repository_branch."
  }
}

variable "git_repository_branch" {
  type        = string
  description = "Git source reference (branch name, tag, or commit SHA). Use 'skipped' to default to account variable custom_template_library_fetch_key"
  default     = "skipped"
}

// Kubernetes Configurations and Settings
variable "kubernetes_connector" {
  type        = string
  description = "Kubernetes connector reference for pipeline execution (use 'skipped' for Harness-managed infrastructure)"
  default     = "skipped"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace for pipeline execution"
  default     = "default"
}

variable "kubernetes_serviceaccount" {
  type        = string
  description = "Kubernetes service account for pipeline execution (use 'skipped' for default)"
  default     = "skipped"
}

variable "kubernetes_override_run_as_user" {
  type        = string
  description = "Kubernetes pod runAs user ID override (must be a valid Unix integer, or 'skipped')"
  default     = "skipped"

  validation {
    condition = (
      var.kubernetes_override_run_as_user != null
      ?
      var.kubernetes_override_run_as_user != "skipped"
      ?
      can(tonumber(var.kubernetes_override_run_as_user))
      :
      true
      :
      false
    )
    error_message = "Kubernetes runAs user must be a valid Unix integer or 'skipped'."
  }
}

variable "kubernetes_node_selectors" {
  type        = map(any)
  description = "Kubernetes node selectors for pod scheduling"
  default     = {}
}

variable "kubernetes_override_image_connector" {
  type        = string
  description = "Container registry connector for custom provisioner images (use 'skipped' for default)"
  default     = "skipped"
}

variable "kubernetes_override_image_name" {
  type        = string
  description = "Custom container image for provisioner (terraform/opentofu binary). Path relative to kubernetes_override_image_connector"
  default     = "skipped"
}

variable "provisioner_type" {
  type        = string
  description = "Default provisioner type: 'terraform' or 'opentofu'"
  default     = "opentofu"
}

variable "provisioner_version" {
  type        = string
  description = "Default provisioner version for all deployments"
  default     = "1.10.0"
}

variable "hsf_pipeline_connector_ref" {
  type        = string
  description = "Container registry connector for HSF pipeline images"
  default     = "org.hsf_dockerhub_connector"
}

variable "hsf_script_mgr_image" {
  type        = string
  description = "HSF Script Manager image (relative to hsf_pipeline_connector_ref)"
  default     = "harnesssolutionfactory/harness-python-api-sdk:v1.13.0"
}

variable "hsf_idp_resource_mgr_image" {
  type        = string
  description = "HSF IDP Resource Manager image (relative to hsf_pipeline_connector_ref)"
  default     = "harnesssolutionfactory/harness-idp-resource-manager:v1.3.5"
}

variable "hsf_iacm_manager_plugin" {
  type        = string
  description = "HSF IACM Workspace Manager plugin image (relative to hsf_pipeline_connector_ref)"
  default     = "harnesssolutionfactory/harness-manage-iacm-workspace:v1.7.6"
}

variable "enable_hsf_mini_factory" {
  type        = string
  description = "Enable Mini-Factory for distributed IDP workflow execution"
  default     = false
}

variable "should_use_harness_idp" {
  type        = bool
  description = "Enable Harness IDP for the Solutions Factory"
  default     = true
}

variable "should_use_hsf_hub" {
  type        = bool
  description = "Deploy the HSF Hub for centralized workspace management"
  default     = false
}

variable "hsf_plugin_ssl_verify_x509_strict" {
  type        = bool
  description = "Enforce strict SSL RFC5280 compliance for HSF plugins"
  default     = true
}


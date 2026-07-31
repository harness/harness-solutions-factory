// Harness Account Connection
variable "harness_platform_url" {
  type        = string
  description = "Harness Platform URL (defaults to Harness SaaS)"
  default     = "https://app.harness.io/gateway"
}

variable "harness_platform_account" {
  type        = string
  description = "Harness Platform Account Number (falls back to HARNESS_ACCOUNT_ID env var)"
}

variable "harness_platform_key" {
  type        = string
  description = "Harness Platform API Key for authentication (falls back to HARNESS_PLATFORM_API_KEY env var)"
  sensitive   = true
}

variable "store_backend" {
  type        = bool
  description = "Store Generated Backend configuration file when running locally"
  default     = false
}

// Custom Configuration and Feature Flags
variable "existing_harness_platform_key_ref" {
  type        = string
  description = <<-EOH
    Reference to existing Harness Platform API key (secret reference). If not provided, then a new account-level account
    will be created and the token stored as a secret in the Harness Secrets manager as `org.hsf_platform_api_key`
  EOH
  default     = "skipped"
}

variable "should_setup_custom_tpl" {
  type        = bool
  description = "Enable creating local Harness Code repository for custom configurations"
  default     = false
}

variable "should_unpack" {
  type        = bool
  description = "Enable unpacking the Solutions Factory deployment"
  default     = false
}

variable "should_use_harness_idp" {
  type        = bool
  description = "Enable Harness IDP for the Solutions Factory"
  default     = true
}

variable "initial_admin_user" {
  type        = string
  description = "Email address of primary HSF admin user"
}

// SCM Source Configurations for IACM Workspaces
variable "hsf_source_connector" {
  type        = string
  description = "SCM connector reference for IACM workspaces (use 'skipped' for official repositories; prefix account/org connectors with 'account.' or 'org.' as needed)"
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
  default     = "v2.5.2"
}

// Kubernetes Configurations for Pipeline Execution
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

// Provisioner Configuration
variable "provisioner_type" {
  type        = string
  description = "Default provisioner type: 'terraform' or 'opentofu'"
  default     = "opentofu"
}

variable "provisioner_version" {
  type        = string
  description = "Default provisioner version for all deployments"
  default     = "1.12.3"
}

// HSF Master Service Account Token Rotation
variable "should_rotate_on_schedule" {
  type        = bool
  description = "Enable scheduled rotation of Solutions Factory service account tokens"
  default     = true
}

variable "rotation_schedule" {
  type        = string
  description = "Cron schedule for token rotation (default: every Sunday at 03:00 UTC)"
  default     = "0 3 * * 0"
}

// HSF Plugin Configurations
variable "hsf_pipeline_connector_ref" {
  type        = string
  description = "Container registry connector for HSF pipeline images (defaults to skipped)"
  default     = "skipped"
}

variable "hsf_script_mgr_image" {
  type        = string
  description = "HSF Script Manager image (relative to hsf_pipeline_connector_ref)"
  default     = "harnesssolutionfactory/harness-python-api-sdk:v1.14.0"
}

variable "hsf_rotate_token_plugin" {
  type        = string
  description = "HSF Token Rotation plugin image (relative to hsf_pipeline_connector_ref)"
  default     = "harnesssolutionfactory/harness-token-rotation:v1.2.4"
}

variable "hsf_iacm_manager_plugin" {
  type        = string
  description = "HSF IACM Workspace Manager plugin image (relative to hsf_pipeline_connector_ref)"
  default     = "harnesssolutionfactory/harness-manage-iacm-workspace:v1.7.7"
}

variable "hsf_idp_resource_mgr_image" {
  type        = string
  description = "HSF IDP Resource Manager image (relative to hsf_pipeline_connector_ref)"
  default     = "harnesssolutionfactory/harness-idp-resource-manager:v1.3.6"
}

variable "hsf_plugin_ssl_verify_x509_strict" {
  type        = bool
  description = "Enforce strict SSL RFC5280 compliance for HSF plugins"
  default     = true
}

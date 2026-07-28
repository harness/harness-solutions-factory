// Harness Account Connection
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
  description = "The Harness project ID where factory-floor will be deployed"
}

variable "should_create_hsf_core_mgr_workspace" {
  type        = bool
  description = "Create HSF Core Manager workspace (only valid when should_use_harness_idp is false)"
  default     = true
}

variable "should_use_harness_idp" {
  type        = bool
  description = "Enable Harness IDP for the Solutions Factory"
  default     = null
}

// Factory Floor Master configuration
variable "existing_harness_platform_key_ref" {
  type        = string
  description = "Reference to existing Harness Platform API key (secret reference)"
  default     = null
}

variable "git_connector_ref" {
  type        = string
  description = "Git connector reference for template library deployment"
  default     = null
}

variable "git_repository_name" {
  type        = string
  description = "Git repository name for template library"
  default     = null
}

variable "git_repository_branch" {
  type        = string
  description = "Git source reference (branch name, tag, or commit SHA)"
  default     = null
}

// Kubernetes Configurations and Settings
variable "kubernetes_connector" {
  type        = string
  description = "Kubernetes connector reference for pipeline execution"
  default     = null
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace for pipeline execution"
  default     = null
}

variable "kubernetes_serviceaccount" {
  type        = string
  description = "Kubernetes service account for pipeline execution"
  default     = null
}

variable "kubernetes_override_run_as_user" {
  type        = string
  description = "Kubernetes pod runAs user ID override (must be a valid Unix integer or null)"
  default     = null

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
      true
    )
    error_message = "Kubernetes runAs user must be a valid Unix integer or null."
  }
}

variable "kubernetes_node_selectors" {
  type        = map(any)
  description = "Kubernetes node selectors for pod scheduling"
  default     = {}
}

variable "kubernetes_override_image_connector" {
  type        = string
  description = "Container registry connector for custom provisioner images"
  default     = null
}

variable "kubernetes_override_image_name" {
  type        = string
  description = "Custom container image for provisioner (terraform/opentofu binary). Path relative to kubernetes_override_image_connector"
  default     = null
}

// Provisioner Type and Version
variable "provisioner_type" {
  type        = string
  description = "Default provisioner type: 'terraform' or 'opentofu'"
  default     = null
}

variable "provisioner_version" {
  type        = string
  description = "Default provisioner version for all deployments"
  default     = null
}

// HSF Plugin Configurations and Settings
variable "hsf_pipeline_connector_ref" {
  type        = string
  description = "Container registry connector for HSF pipeline images (defaults to org.hsf_dockerhub_connector)"
  default     = null
}

variable "hsf_script_mgr_image" {
  type        = string
  description = "HSF Script Manager image (relative to hsf_pipeline_connector_ref)"
  default     = null
}

variable "hsf_iacm_manager_plugin" {
  type        = string
  description = "HSF IACM Workspace Manager plugin (relative to hsf_pipeline_connector_ref)"
  default     = null
}

variable "hsf_idp_resource_mgr_image" {
  type        = string
  description = "HSF IDP Resource Manager image (relative to hsf_pipeline_connector_ref)"
  default     = null
}

variable "hsf_rotate_token_plugin" {
  type        = string
  description = "HSF Token Rotation plugin image (relative to hsf_pipeline_connector_ref)"
  default     = null
}

variable "hsf_plugin_ssl_verify_x509_strict" {
  type        = bool
  description = "Enforce strict SSL RFC5280 compliance for HSF plugins"
  default     = null
}

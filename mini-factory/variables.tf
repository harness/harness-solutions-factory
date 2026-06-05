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

variable "organization_id" {
  type        = string
  description = "Harness organization ID (must exist before execution)"
  default     = "Harness_Platform_Management"
}

variable "project_id" {
  type        = string
  description = "Mini-Factory project identifier"
}

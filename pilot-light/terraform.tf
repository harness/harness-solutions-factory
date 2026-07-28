// Terraform configuration with required provider versions
terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    // Harness provider for platform resource management
    harness = {
      source  = "harness/harness"
      version = ">= 0.41"
    }
    // Time provider for managing delays and waits
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14.0"
    }
    // Local provider for file operations and data sources
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
}

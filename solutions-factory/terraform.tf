terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    // Harness Terraform provider for managing platform resources
    harness = {
      source  = "harness/harness"
      version = ">= 0.45"
    }
    // 2026-08-21
    // Deprecated
    // Time provider for managing delays and waits
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14.0"
    }
  }
}

terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    // Harness Terraform provider for managing platform resources
    harness = {
      source  = "harness/harness"
      version = ">= 0.45"
    }
  }
}

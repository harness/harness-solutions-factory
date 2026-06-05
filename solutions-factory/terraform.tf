terraform {
  required_providers {
    // Harness Terraform provider for managing platform resources
    harness = {
      source  = "harness/harness"
      version = ">= 0.41"
    }
    // Time provider for managing time-based operations
    time = {
      source = "hashicorp/time"
    }
  }
}

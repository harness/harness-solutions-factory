terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.41"
    }
  }
}

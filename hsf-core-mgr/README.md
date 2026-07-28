# Harness Core Manager

Placeholder module for HSF Core Manager workspace integration.

## Summary

This directory serves as a placeholder for Core Manager workspace configuration. When IDP is disabled in Factory Floor deployments, a dedicated core management workspace may be created using this module for centralized resource and policy management.

**Note**: This module does not currently provision any resources. It is reserved for future Core Manager functionality and workspace management capabilities.

## Providers

This module requires the [Harness Provider](https://registry.terraform.io/providers/harness/harness/latest/docs) (version >= 0.31) when extended for Core Manager functionality.

### Required Provider Configuration

```hcl
terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.41"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}

provider "harness" {
  endpoint         = var.harness_platform_url
  account_id       = var.harness_platform_account
  platform_api_key = var.harness_platform_key
}
```

**Note**: The gitignore file in this repository explicitly ignores any file called `providers.tf` from commits.

## Prerequisites

**Required**:
- Harness API Key: Account-level API key with Admin permissions
- Harness Account Number: Your Harness account ID
- Existing Organization: Target organization must exist in the Harness account

## Variables

Variables will be defined when Core Manager resources are implemented.

## Configuration

Configuration details will be provided when this module is extended with Core Manager functionality.

## Outputs

No outputs are currently generated from this placeholder module.

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

Business Source License 1.1. See [LICENSE](../LICENSE) for full details.

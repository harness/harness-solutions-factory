# Harness Solutions Factory - Mini Factory

This Terraform template deploys a dedicated Factory Floor project within a specified organization, enabling distributed workspace management across organizational boundaries.

## Summary

The Mini Factory concept distributes HSF Factory Floor capabilities across multiple projects, one per organization. Rather than centralizing all IACM workspaces in a single Solutions Factory project, Mini Factory creates organizational-scoped factory projects where resources requested for that organization are deployed locally.

This template provisions:

- A new Harness Project in the target Organization
- Complete Factory Floor deployment (pipelines, roles, RBAC controls)
- Organizational workspace isolation and management capabilities
- Day-Zero through Day-180 operations for workspace lifecycle management


## Quick Start

Prerequisites: Install [OpenTofu](https://opentofu.org/) or [Terraform](https://developer.hashicorp.com/terraform/install) on your local machine.

**Note**: Mini Factory should be deployed into the `Harness_Platform_Management` organization after Pilot Light and Solutions Factory initialization.

1. Clone this repository and navigate to the `mini-factory` directory
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required values
3. Run the following commands:

**Using OpenTofu**:
```bash
tofu init
tofu plan
tofu apply
# Review the plan and confirm
```

**Using Terraform**:
```bash
terraform init
terraform plan
terraform apply
# Review the plan and confirm
```

## Providers

This module requires the [Harness Provider](https://registry.terraform.io/providers/harness/harness/latest/docs) (version >= 0.31). Required credentials must be provided via Terraform variables or environment variables (`HARNESS_ACCOUNT_ID`, `HARNESS_PLATFORM_API_KEY`).

### Required Provider Configuration

Included in the parent module is `providers.tf` with the provider declaration:

```hcl
terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.31"
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

Pass credentials via `terraform.tfvars` or environment variables, not hardcoded values.

**Note**: The gitignore file in this repository explicitly ignores any file called `providers.tf` from commits.

## Prerequisites

**Required**:
- Harness API Key: Account-level API key with Admin permissions
- Harness Account Number: Your Harness account ID
- Harness Solutions Factory version >= 2.3.0
- Target Organization: Must exist in the Harness account

## Variables

**Note**: For `_ref` variables, prefix with `org.` or `account.` depending on scope; project-level connectors need no prefix.

### Connection (Required)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `harness_platform_account` | Harness account number | string | *required* |
| `harness_platform_key` | Harness API key with Admin permissions | string | *required* |
| `harness_platform_url` | Harness platform URL | string | `https://app.harness.io/gateway` |

### Project Configuration (Required)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `project_id` | Project identifier for the new Mini Factory project | string | *required* |
| `organization_id` | Organization where project will be created | string | `Harness_Platform_Management` |

### Optional

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `tags` | Tags to associate with created resources | map(any) | `{}` |


## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required values. See the Variables section above for detailed descriptions.

## Outputs

After successful `apply`, the new project is created and Factory Floor resources are deployed. The project can be used immediately to manage IACM workspaces within the organization.

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

Business Source License 1.1. See [LICENSE](../LICENSE) for full details.

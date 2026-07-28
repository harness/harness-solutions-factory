# Harness Solutions Factory Hub

This Terraform template deploys the HSF Hub project with API-driven workspace provisioning pipelines, enabling integration with external service portals like Jira, ServiceNow, and Backstage.

## Summary

HSF Hub brings all HSF workspace management workflows into a centralized Hub project as API-triggered pipelines. Unlike IDP-based HSF, Hub workflows are independent pipelines that can be invoked through HTTP APIs, enabling seamless integration with existing service portals and automated workflows.

This template provisions:

- Central `HSF Hub` project with workspace provisioning pipelines
- Project roles: `Shared_Resource_Access` and `LandingZoneOperator`
- RBAC group bindings: Default access for HSF_Admins and HSF_Users groups
- Hub-specific pipelines loaded from the content library registration
- API-accessible endpoints for third-party service integration
- Resource groups and role bindings from registered content library

## Quick Start

Prerequisites: Install [OpenTofu](https://opentofu.org/) or [Terraform](https://developer.hashicorp.com/terraform/install) on your local machine.

**Note**: HSF Hub should be deployed after Solutions Factory and Pilot Light initialization.

1. Clone this repository and navigate to the `hsf-hub` directory
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values
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

This module requires the [Harness Provider](https://registry.terraform.io/providers/harness/harness/latest/docs) (version >= 0.41). Required credentials must be provided via Terraform variables or environment variables (`HARNESS_ACCOUNT_ID`, `HARNESS_PLATFORM_API_KEY`).

### Required Provider Configuration

Included in the parent module is `providers.tf` with the provider declaration:

```hcl
terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.41"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14.0"
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
- Git Repository Configuration: Repository containing Hub content library and pipeline definitions
- Hub Content Library: Git repository with `hub_registration_mgr.yaml` and associated pipeline configurations

## Variables

**Note**: For `_ref` variables, prefix with `org.` or `account.` depending on scope; project-level connectors need no prefix.

### Connection (Required)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `harness_platform_account` | Harness account number | string | *required* |
| `harness_platform_url` | Harness platform URL | string | `https://app.harness.io/gateway` |

### Project Configuration

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `organization_id` | Organization reference | string | `Harness_Platform_Management` |
| `project_id` | Hub project identifier (auto-formatted if not provided) | string | null |
| `project_name` | Hub project display name | string | `HSF Hub` |
| `project_description` | Hub project description | string | `Central Hub for Harness Solutions Factory` |
| `tags` | Tags to associate with resources | map(any) | `{}` |

### Content Library Configuration

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `content_library_connector` | Git connector for content library | string | null |
| `content_library_repo` | Repository name for content library | string | null |
| `content_library_branch` | Branch for content library | string | `main` |
| `content_library` | Absolute path to content library in repository | string | `/harness/content-library` |
| `registration_mgr` | Registration manager filename | string | `hub_registration_mgr.yaml` |

### Workspace Management (Target for Hub Deployments)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `workspace_mgmt_organization_id` | Organization for workspace deployment | string | `Harness_Platform_Management` |
| `workspace_mgmt_project_id` | Project for workspace deployment | string | `Solutions_Factory` |
| `workspace_mgmt_pipeline_id` | Pipeline for workspace provisioning | string | `Create_and_Manage_IACM_Workspaces` |

## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required values. See the Variables section above for detailed descriptions.

## Outputs

| Output Name | Description |
| --- | --- |
| `organization_identifier` | Hub hosting organization identifier |
| `project_identifier` | Newly created Hub project identifier |
| `project_url` | Harness Hub project URL |

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

Business Source License 1.1. See [LICENSE](../LICENSE) for full details.

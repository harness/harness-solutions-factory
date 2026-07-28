# Harness Solutions Factory

This Terraform template initializes the complete Harness Solutions Factory (HSF) infrastructure in a ready Harness account, creating centralized workspace automation and Day-2 operations pipelines.

## Summary

The Harness Solutions Factory is an integrated platform for managing Harness IACM workspaces at scale. It provides a comprehensive set of pipelines that create, manage, validate, and operate IACM infrastructure across organizations.

This template provisions:

- Core workspace management pipelines with Step Group Templates
- Day-2 operational pipelines for provisioning, validation, drift analysis, and teardown
- IDP resource management and integration workflows
- Central Solutions Factory Project with shared templates and connectors
- Base infrastructure projects: Image Factory and Delegate Management
- Project variables for Harness API connectivity
- RBAC controls and resource groups for secure access

## Quick Start

Prerequisites: Install [OpenTofu](https://opentofu.org/) or [Terraform](https://developer.hashicorp.com/terraform/install) on your local machine.

**Note**: This template should be deployed after Pilot Light initialization.

1. Clone this repository and navigate to the `solutions-factory` directory
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

Pass credentials via `terraform.tfvars` or environment variables:
- `HARNESS_ACCOUNT_ID` — Harness account number
- `HARNESS_PLATFORM_API_KEY` — Harness API key

## Prerequisites

**Required**:
- Harness API Key: Account-level API key with Admin permissions
- Harness Account Number: Your Harness account ID
- Existing Organization: Target organization must exist in the Harness account
- Git Repository Configuration: Git connector and repository for deployment
- This repository hosted in a location retrievable by the Git Repository Connector

**Optional: Self-Hosted Execution**:
- Kubernetes Connector with namespace access for pipeline execution
- Harness Delegate installed in the target cluster

## Variables

**Note**: For `_ref` variables, prefix with `org.` or `account.` depending on scope; project-level connectors need no prefix.

### Connection (Required)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `harness_platform_account` | Harness account number | string | *required* |
| `harness_platform_url` | Harness platform URL | string | `https://app.harness.io/gateway` |

### Git Configuration (Required)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `existing_harness_platform_key_ref` | Reference to existing Harness API key secret | string | *required* |
| `git_connector_ref` | Git repository connector reference | string | *required* |
| `git_repository_name` | Git repository name | string | *required* |
| `git_repository_branch` | Git branch for deployment | string | `main` |

### Project Configuration

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `organization_id` | Organization reference | string | `Harness_Platform_Management` |
| `project_id` | Solutions Factory project identifier | string | `Solutions_Factory` |

### Kubernetes (Optional)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `kubernetes_connector` | Connector reference for K8s execution | string | `skipped` |
| `kubernetes_namespace` | Namespace for pipeline execution | string | `default` |
| `kubernetes_serviceaccount` | Service account for K8s pods | string | `skipped` |
| `kubernetes_override_run_as_user` | Unix UID for pod security context | string | `skipped` |
| `kubernetes_node_selectors` | Node selectors for pod scheduling | map(any) | `{}` |
| `kubernetes_override_image_connector` | Custom container registry connector | string | `skipped` |
| `kubernetes_override_image_name` | Custom IACM provisioner image | string | `skipped` |

### Provisioner

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `provisioner_type` | Tool: `terraform` or `opentofu` | string | `opentofu` |
| `provisioner_version` | Provisioner version | string | `1.12.3` |

### HSF Plugins and Features

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `hsf_pipeline_connector_ref` | Connector for HSF plugin images | string | `org.hsf_dockerhub_connector` |
| `hsf_script_mgr_image` | Script Manager image path | string | `harnesssolutionfactory/harness-python-api-sdk:v1.14.0` |
| `hsf_rotate_token_plugin` | Token Rotation plugin image | string | `harnesssolutionfactory/harness-token-rotation:v1.2.4` |
| `hsf_iacm_manager_plugin` | IACM Workspace Manager plugin image | string | `harnesssolutionfactory/harness-manage-iacm-workspace:v1.7.7` |
| `hsf_idp_resource_mgr_image` | IDP Resource Manager image | string | `harnesssolutionfactory/harness-idp-resource-manager:v1.3.6` |
| `hsf_plugin_ssl_verify_x509_strict` | Enforce strict SSL/X.509 validation | bool | `true` |
| `enable_hsf_mini_factory` | Enable Mini Factory configuration | bool | `false` |
| `should_use_harness_idp` | Enable Harness IDP integration | bool | `true` |
| `should_use_hsf_hub` | Deploy HSF Hub | bool | `false` |

## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required values. See the Variables section above for detailed descriptions.

## Outputs

After successful `apply`, the Solutions Factory is ready for workspace management operations. All core pipelines and infrastructure are deployed and accessible through the Harness platform.

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

Business Source License 1.1. See [LICENSE](../LICENSE) for full details.

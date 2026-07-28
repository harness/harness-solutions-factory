# Harness Solutions Factory - Factory Floor

This Terraform template deploys the core operational pipelines and RBAC controls for managing Harness IACM workspace lifecycle within the Solutions Factory.

## Summary

The Factory Floor provides a complete suite of operational pipelines for Day-Zero through Day-180 IACM workspace management, including creation, provisioning, validation, drift detection, and teardown. It establishes project roles, access controls, and automated workflow pipelines within an existing Harness project.

This template creates:

- Project roles: `Shared_Resource_Access` and `HSF_IACM_Executor`
- Resource groups and policies for workspace execution control
- Operational pipelines: Create and Manage Workspaces, Provision, Plan and Validate, Drift Analysis, Teardown, and Rotate Harness Service Account Token
- Bulk workspace management capabilities with tag-based filtering
- IDP integration for automated drift state tracking (optional)
- Automated API token rotation and secret management

## Quick Start

Prerequisites: Install [OpenTofu](https://opentofu.org/) or [Terraform](https://developer.hashicorp.com/terraform/install) on your local machine.

**Note**: This module is typically deployed after Pilot Light has been initialized.

1. Clone this repository and navigate to the `factory-floor` directory
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

This module requires the [Harness Provider](https://registry.terraform.io/providers/harness/harness/latest/docs) (version >= 0.41). Required credentials must be provided via Terraform variables or environment variables (`HARNESS_ACCOUNT_ID`, `HARNESS_PLATFORM_API_KEY`).

### Required Provider Configuration

Included in the parent module is `providers.tf` with the provider declaration:

```hcl
terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.41"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

provider "harness" {
  endpoint         = var.harness_platform_url
  account_id       = var.harness_platform_account
  platform_api_key = var.harness_platform_key
}
```

Alternatively, set environment variables:
- `HARNESS_ACCOUNT_ID` — Harness account number
- `HARNESS_PLATFORM_API_KEY` — Harness API key

## Prerequisites

**Required**:
- Harness API Key: Account-level API key with Admin permissions
- Harness Account Number: Your Harness account ID
- Existing Harness Project: Project where factory floor will be deployed
- Git Configuration: Git connector and repository for IACM workspace code

**Optional: Self-Hosted Execution**:
- Kubernetes Connector with namespace access for pipeline execution
- Harness Delegate installed in the target cluster

## Variables

**Note**: Variables here override those in the `harness-solutions-factory` IACM workspace (Harness_Platform_Management/Solutions_Factory). When `null`, workspace values are used instead.

**Note**: For `_ref` variables, prefix with `org.` or `account.` as needed; project-level connectors need no prefix.

### Connection (Required)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `project_id` | Project where factory floor will be deployed | string | *required* |
| `harness_platform_account` | Harness account number | string | `null` (uses `HARNESS_ACCOUNT_ID` env var) |
| `harness_platform_url` | Harness platform URL | string | `https://app.harness.io/gateway` |
| `organization_id` | Organization reference | string | `Harness_Platform_Management` |

### Git and Code Repository

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `git_connector_ref` | Git connector for IACM workspace code | string | `null` |
| `git_repository_name` | Repository name | string | `null` |
| `git_repository_branch` | Branch to deploy from | string | `null` |
| `existing_harness_platform_key_ref` | Harness API key reference | string | `null` |

### Kubernetes (Optional)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `kubernetes_connector` | Connector reference for K8s execution | string | `null` |
| `kubernetes_namespace` | Namespace for pipeline execution | string | `null` |
| `kubernetes_serviceaccount` | Service account for K8s pods | string | `null` |
| `kubernetes_override_run_as_user` | Unix UID for pod security context | string | `null` |
| `kubernetes_node_selectors` | Node selectors for pod scheduling | map(any) | `{}` |
| `kubernetes_override_image_connector` | Custom container registry connector | string | `null` |
| `kubernetes_override_image_name` | Custom IACM provisioner image | string | `null` |

### Provisioner

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `provisioner_type` | Tool: `terraform` or `opentofu` | string | `null` |
| `provisioner_version` | Provisioner version | string | `null` |

### Factory Floor and IDP

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `should_use_harness_idp` | Enable Harness IDP integration | bool | `null` |
| `should_create_hsf_core_mgr_workspace` | Create core management workspace (requires IDP disabled) | bool | `true` |

### HSF Plugins

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `hsf_pipeline_connector_ref` | Connector for HSF plugin images | string | `null` |
| `hsf_script_mgr_image` | Script Manager image path | string | `null` |
| `hsf_rotate_token_plugin` | Token Rotation plugin image | string | `null` |
| `hsf_iacm_manager_plugin` | IACM Workspace Manager plugin image | string | `null` |
| `hsf_idp_resource_mgr_image` | IDP Resource Manager image | string | `null` |
| `hsf_plugin_ssl_verify_x509_strict` | Enforce strict SSL/X.509 validation in plugins | bool | `null` |

## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required values. See the Variables section above for detailed descriptions.

**Note**: Most variables default to `null` to inherit from the Pilot Light workspace configuration, allowing this module to be deployed as-is after Pilot Light initialization.

## Outputs

| Output Name | Description |
| --- | --- |
| bulk_management_pipeline_id | Identifier for the Bulk IACM Workspace Management pipeline |
| create_manage_pipeline_id | Identifier for the Create and Manage Workspace pipeline |
| drift_analysis_pipeline_id | Identifier for the Drift Analysis pipeline |
| plan_validate_pipeline_id | Identifier for the Plan and Validate pipeline |
| provision_workspace_pipeline_id | Identifier for the Infrastructure Provisioning pipeline |
| teardown_workspace_pipeline_id | Identifier for the Infrastructure Teardown pipeline |

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

Business Source License 1.1. See [LICENSE](../LICENSE) for full details.

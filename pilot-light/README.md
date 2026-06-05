# Harness Solutions Factory - Pilot Light

This Terraform template sets up the minimal components required to deploy the Harness Solutions Factory (HSF) into a new Harness account.

## Summary

The Pilot Light provisions foundational Harness resources needed for the Solutions Factory deployment. It creates the infrastructure and tooling that enables subsequent pipelines to deploy the complete solutions factory. This template creates:

- A new organization: `Harness Platform Management - HSF`
- A new project: `Solutions Factory`
- A service account: `harness-platform-manager` with account-level admin permissions
- Harness Code Repositories and Connectors for the Solutions Factory and Template Library (optional)
- IACM workspaces: `Harness Solutions Factory` (deployment) and `Harness Pilot Light` (management)
- A DockerHub connector for HSF plugin container images
- Automated scheduling for repository mirroring and token rotation

## Quick Start

Prerequisites: Install [OpenTofu](https://opentofu.org/) or [Terraform](https://developer.hashicorp.com/terraform/install) on your local machine.

**Note**: ⚠️  Minimum configuration requires your Harness Account Number and an API Key with Account Admin permissions.

**Note**: ⚠️ When running locally to initialize the pilot-light, you will want to configure the `store_backed` variable to push the statefile to the new Harness IACM Workspace.

1. Clone this repository and navigate to the `pilot_light` directory
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values
3. Run the following commands:

**Using OpenTofu**:
```bash
tofu init
tofu apply
# After execution, run `init` and follow the instructions to copy the current state to the remote.
tofu init  # Upload state to Harness IACM workspace
```

**Using Terraform**:
```bash
terraform init
terraform apply
# After execution, run `init` and follow the instructions to copy the current state to the remote.
terraform init  # Upload state to Harness IACM workspace
```

Review the output and follow all post-deployment steps.

## Providers

This module requires the [Harness Provider](https://registry.terraform.io/providers/harness/harness/latest/docs) (version >= 0.41). Required credentials must be provided via Terraform variables, not environment variables.

### Required Provider Configuration

Included in this template is `providers.tf` with the provider declaration:

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
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
}

provider "harness" {
  endpoint         = var.harness_platform_url
  account_id       = var.harness_platform_account
  platform_api_key = var.harness_platform_key
}
```

Pass credentials via `terraform.tfvars` or command-line variables, not environment variables.

## Prerequisites

- **Harness API Key**: Account-level API key with Admin permissions
- **Harness Account Number**: Your Harness account ID

### Optional: Self-Hosted Execution

If using self-hosted build infrastructure instead of Harness Cloud:
- Kubernetes Connector with namespace access for pipeline execution
- Harness Delegate installed in the target cluster

### State Management

After the initial local `apply`, run `init` again to push the local state to the Harness IACM workspace for centralized management.

## Variables

### Connection (Required)

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `harness_platform_account` | Harness account number | string | *required* |
| `harness_platform_key` | Harness API key with Admin permissions | string | *required* |
| `harness_platform_url` | Harness platform URL | string | `https://app.harness.io/gateway` |

### Custom Configuration and Feature Flags

_**NOTE**: This option should only be used when performing an initial setup of HSF Pilot Light from a local development workstation._

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `store_backend` | Store Generated Backend configuration file when running locally | bool | `false` |
| `should_setup_custom_tpl` | Enable creating local Harness Code repository for custom configurations | bool | `false` |
| `should_unpack` | Enable unpacking the Solutions Factory deployment | bool | `false` |
| `should_use_harness_idp` | Enable Harness IDP for the Solutions Factory | bool | `true` |
| `initial_admin_user` | Email address of primary HSF admin user (use 'skipped' to defer) | string | "skipped" |

### Source Control

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `scm_source_connector` | SCM connector reference; use `org.` or `account.` prefix as needed | string | `skipped` |
| `scm_source_repository` | Repository name to use for IACM workspaces | string | `harness-solutions-factory` |
| `scm_source_fetch_type` | Fetch type: `branch`, `tag`, or `sha` | string | `tag` |
| `scm_source_branch` | Branch/tag/SHA to fetch | string | `v2.5.0` |

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
| `provisioner_version` | Provisioner version | string | `1.10.0` |

### Repository and Automation

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `should_rotate_on_schedule` | Enable token rotation schedule | bool | `true` |
| `rotation_schedule` | Cron schedule for token rotation (UTC) | string | `0 3 * * 0` |
| `should_setup_custom_tpl` | Create custom template library repository | bool | `true` |
| `should_use_harness_idp` | Enable Harness IDP integration | bool | `true` |
| `initial_admin_user` | Email of primary HSF admin | string | `skipped` |

### HSF Plugins

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `hsf_pipeline_connector_ref` | Connector for HSF plugin images | string | `org.hsf_dockerhub_connector` |
| `hsf_script_mgr_image` | Script Manager image path | string | `harnesssolutionfactory/harness-python-api-sdk:latest` |
| `hsf_mirror_repos_plugin` | Repository Mirror plugin image | string | `harnesssolutionfactory/harness-cr-mirror-repositories:latest` |
| `hsf_rotate_token_plugin` | Token Rotation plugin image | string | `harnesssolutionfactory/harness-token-rotation:latest` |
| `hsf_iacm_manager_plugin` | IACM Workspace Manager plugin image | string | `harnesssolutionfactory/harness-manage-iacm-workspace:latest` |
| `hsf_idp_resource_mgr_image` | IDP Resource Manager image | string | `harnesssolutionfactory/harness-idp-resource-manager:latest` |
| `hsf_plugin_ssl_verify_x509_strict` | Enforce strict SSL/X.509 validation in plugins | bool | `true` |

**Note**: For `_ref` variables, prefix with `org.` or `account.` depending on scope; project-level connectors need no prefix.

## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required values. See the Variables section above for detailed descriptions.

## Outputs

After successful `apply`, Terraform displays `next_steps` output with instructions for completing the HSF deployment. Follow all post-deployment steps to finalize the configuration.

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

Business Source License 1.1. See [LICENSE](../LICENSE) for full details.

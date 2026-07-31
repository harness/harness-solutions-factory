# Changelog

All notable changes to the Harness Solutions Factory Pilot Light module are documented in this file.

## v2.5.2

### Updated
- Refactored pilot-light workspace to remove redundant SCM source and provisioner terraform variables, consolidating configuration management
- Updated default HSF source branch from v2.5.1 to v2.5.2
- Git connector URL reverted from goodrum-harness to official harness organization
- Added repository connector and branch/commit/sha references to pilot-light workspace ignore_changes list to preserve custom repository configuration

### Removed
- Redundant terraform variables from pilot-light workspace: `hsf_source_repository`, `hsf_source_fetch_type`, `hsf_source_branch`, `provisioner_type`, `provisioner_version`
- Redundant terraform variables from solutions-factory workspace: `hsf_source_connector`, `hsf_source_repository`, `hsf_source_fetch_type`, `hsf_source_branch`, `provisioner_type`, `provisioner_version`

## v2.5.1

### Added
- Support for existing Harness Platform API key reference via `existing_harness_platform_key_ref` variable for bring-your-own setup
- Dynamic HSF plugin workspace variables configuration for consolidated management
- Conditional Docker connector creation based on `hsf_pipeline_connector_ref` variable
- Explicit Terraform version requirement (>= 1.10.0, < 2.0.0)
- Explicit identifiers to role assignment resources for improved state management

### Changed
- Service account, API key, token, and secret resources now conditionally created based on `should_create_service_account` flag
- Updated default HSF plugin image versions:
  - Script Manager: v1.13.0 → v1.14.0
  - Token Rotation: v1.2.3 → v1.2.4
  - IACM Workspace Manager: v1.7.6 → v1.7.7
  - IDP Resource Manager: v1.3.5 → v1.3.6
- Updated default provisioner version from 1.10.0 to 1.12.3
- Updated time provider version from ~> 0.9.1 to ~> 0.14.0
- Docker connector reference (`hsf_pipeline_connector_ref`) now dynamic with "skipped" as default
- Token rotation pipeline now conditionally created based on `should_create_service_account` flag
- Refactored workspace plugin variable management to use dynamic blocks with consolidated locals
- HSF core manager repository path normalized from `hsf_core_mgr` to `hsf-core-mgr`
- Git connector URL updated to point to goodrum-harness organization
- Configuration file renamed from `terraform.tfvars_example` to `terraform.tfvars.example`
- Fixed documentation typos: `store_backed` → `store_backend`, `pilot_light` → `pilot-light`

### Fixed
- Removed `provider_connector` from HSF core manager workspace ignore_changes list
- Fixed pipeline template variable handling to conditionally render rotate token plugin section
- Fixed hardcoded Docker registry default in pipeline to use template variable

### Removed
- Generic token rotation pipeline (`Rotate_HSF_Token_generic`) replaced with conditional main pipeline
- Static variable definitions from `pipe_Manage_Pilot_Light.yaml` (now handled by workspace configuration)
- Hardcoded `org.hsf_dockerhub_connector` default from pipeline template
- Mirror repositories plugin variable (`hsf_mirror_repos_plugin`) and all references
- Commented-out pipeline template variables
- TF_VAR_harness_platform_key environment variable from solutions_factory workspace configuration
- Pilot light pipeline platform management variables

## v2.5.0

### Added
- Core Harness Platform Management organization and Solutions Factory project
- Service account with account-level admin permissions for resource provisioning
- IACM workspaces for deployment and pilot light management
- Harness Code Repository support with optional local mirroring
- DockerHub connector for HSF plugin container images
- Support for custom template library repositories
- Configurable Kubernetes execution environment (self-hosted or Harness Cloud)
- OpenTofu/Terraform provisioner selection and versioning
- HSF plugin image configuration with SSL validation options
- IACM workspace management pipelines for ongoing HSF resource updates
- Automated repository mirroring and token rotation scheduling
- Support for self-hosted Kubernetes execution configuration
- IDP integration enablement flag

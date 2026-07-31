# Changelog

All notable changes to the Harness Solutions Factory Factory Floor module are documented in this file.

## v2.5.2

### Updated
- Refactored organization and project ID references to use variables (`var.organization_id`, `var.project_id`) instead of data sources across all Terraform configuration files for improved flexibility and consistency
- Enhanced README documentation with detailed provider requirements, directory structure overview, and improved credential configuration guidance
- Updated variable documentation in README to clarify required parameters and provide descriptive defaults for optional configuration options

## v2.5.1

### Added
- Rotate Harness Service Account Token and Secret pipeline for managing token rotation workflows

### Changed
- Pipeline `Create_and_Manage_IACM_Workspaces` supports customizable Approver's Group for Email Notifications. Defaults to `account.HSF_Admins`
- Improved Terraform configuration organization in `terraform.tfvars.example` with section headers and enhanced documentation
- Updated `locals.tf` to safely handle empty Solutions Factory Terraform variable lists
- Fixed Kubernetes node selector logic in `locals.tf` (changed inequality to equality check)
- Refactored variable fallback logic to properly respect input variables over defaults
- Fixed `PLUGIN_HSF_ENABLED` environment variable to use boolean value instead of string in core manager workspace
- Removed `provider_connector` from core manager workspace ignore_changes list
- Removed legacy `hsf_mirror_repos_plugin` variable from configuration
- Reordered `hsf_rotate_token_plugin` variable definition to appear after IDP resource manager
- Updated Terraform version requirement to `>= 1.10.0, < 2.0.0`
- Specified explicit time provider version `~> 0.14.0`
- Improved time provider usage documentation

### Fixed
- Fixed typo in output name: `bulk_managment_pipeline_id` to `bulk_management_pipeline_id`
- Fixed pipeline variable default value format in Create and Manage IACM Workspaces by removing quotes around dynamic expression
- Updated policy documentation comments in Restrict_Factory_Floor_Pipeline_Execution_for_named_workspaces to clarify workspace tag restrictions
- Corrected variable assignments formatting in `harness_groups.tf` for consistent alignment
- Removed deprecated `hsf_mirror_repos_plugin` from README configuration table

### Removed
- Removed legacy Makefile build configuration file

## v2.5.0

### Added
- Complete factory floor pipeline suite for IACM workspace lifecycle management
- Project roles: Shared_Resource_Access and HSF_IACM_Executor
- Resource group (hsf_user_access) for HSF_Users execution scoping
- Policy and Policy Set for factory floor execution control
- Core pipelines:
  - Create and Manage IACM Workspaces
  - Provision Workspace (with approval gates)
  - Teardown IACM Workspace
  - Execute Drift Analysis
  - Plan and Validate IACM Workspace
  - Bulk Workspace Management
- IDP entity drift tracking integration
- Support for Terraform and OpenTofu provisioners
- Configurable HSF plugin images and SSL validation
- Self-hosted and Harness Cloud execution modes

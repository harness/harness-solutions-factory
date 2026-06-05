# Changelog

All notable changes to the Harness Solutions Factory Factory Floor module are documented in this file.

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

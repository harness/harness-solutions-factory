# Changelog

All notable repository-level changes to the Harness Solutions Factory are documented in this file. Detailed, module-specific changes are tracked in the CHANGELOG within each individual Terraform module directory.

## Version v2.5.4
_Harness provider upgrade, remote time provider migration, and documentation improvements_

### Core Module Updates:
- Bump minimum Harness provider version to >= 0.45 (from >= 0.41) across all modules
- Removed HashiCorp time provider dependency (version ~> 0.14.0) from factory-floor, hsf-hub, mini-factory, pilot-light, and solutions-factory modules
- Migrated from HashiCorp time_sleep to Harness native harness_time_sleep resource across all modules for improved integration
- Updated all resource references and dependencies to use harness_time_sleep

### Configuration & Documentation
- Updated provider configuration documentation across all module READMEs to reflect Harness provider >= 0.45 requirement
- Corrected kubernetes_tolerations variable type from list(map(string)) to list(object) in pilot-light, factory-floor, and solutions-factory READMEs
- Updated default HSF source branch references to v2.5.4 across documentation
- Enhanced solutions-factory README with complete variable inventory including HSF source control and git fetch type options
- Added v2.5.4 CHANGELOG entries for all modules documenting infrastructure and operational changes

## Version v2.5.3
_Kubernetes tolerations support and HSF source version bump_

### New Capabilities
- Kubernetes tolerations support across all HSF modules (pilot-light, factory-floor, solutions-factory) via new kubernetes_tolerations variable for advanced pod scheduling on tainted nodes
- Validation for toleration effect, operator, and key/value fields with detailed error messages

### Operational Improvements
- Updated default HSF source branch from v2.5.2 to v2.5.3 across all modules
- Enhanced pipeline templates with tolerations integration in iacm_infrastructure and idp_infrastructure snippets across all modules

## Version v2.5.2
_Configuration consolidation, workspace management refactoring, and improved factory-floor integration across all HSF modules._

### Architecture & Configuration:

- Refactored Solutions Factory workspace from data source to managed importable resource for enhanced configuration control
- Consolidated factory-floor variable passing through Solutions Factory workspace terraform variables
- Extracted workspace terraform variable handling into reusable locals for consistency across modules

### Core Module Updates:

- Factory Floor: Refactored org/project ID references to use variables instead of data sources across all pipeline and resource files
- Mini-Factory: Added Solutions Factory workspace data source for automatic inheritance of factor

## Version v2.5.1
_Infrastructure modernization, plugin updates, and operational improvements across all HSF modules._

### Infrastructure & Dependencies:

- Updated Terraform version requirement to >= 1.10.0, < 2.0.0
- Upgraded Harness provider from >= 0.24/0.31 to >= 0.41
- Updated time provider to ~> 0.14.0 for improved stability

### Plugin & Provisioner Updates:

- Script Manager: v1.13.0 → v1.14.0
- Token Rotation: v1.2.3 → v1.2.4
- IACM Workspace Manager: v1.7.6 → v1.7.7
- IDP Resource Manager: v1.3.5 → v1.3.6
- Default provisioner version: 1.10.0 → 1.12.3

### New Capabilities:

- Added Rotate Harness Service Account Token pipeline for automated token management
- Added support for bring-your-own API key reference (existing_harness_platform_key_ref)
- Conditional Docker connector creation based on configuration

### Operational Improvements:

- Refactored service account and credential management to be conditionally created

## Version v2.5.0
_Initial Migration and Restructure_

### Infrastructure & Modules

- Core Harness Solutions Factory (HSF) platform infrastructure with modular deployment architecture
- Pilot Light module: foundational Harness organization, project, and service account setup with IACM workspace management
- Factory Floor module: operational pipelines for IACM workspace lifecycle (create, provision, plan, validate, drift analysis, teardown)
- HSF Hub module: API-driven workspace provisioning with centralized project and service portal integration
- Mini-Factory module: distributed IDP workflow execution for workspace management at scale
- HSF Core Manager (hsf-core-mgr) module: core management workspace configuration

### Pipelines & Automation

- Complete pipeline suite: Create and Manage IACM Workspaces, Provision, Plan and Validate, Execute Drift Analysis, Teardown, Bulk Workspace Management
- Token rotation and secret management pipelines
- IDP resource management and drift tracking integration
- Deployment pipelines for Factory Floor and HSF Hub modules
- Factory-floor and HSF-Hub operational management pipelines

### RBAC & Security

- Project roles: Shared_Resource_Access, HSF_IACM_Executor, LandingZoneOperator
- Resource groups and policies for workspace execution control and factory management
- Policy sets for factory floor execution scoping and permission management
- Harness user group bindings for HSF_Admins and HSF_Users
- Account-level service account with account admin permissions

### Configuration & Documentation

- Comprehensive module READMEs with provider requirements, setup instructions, and variable documentation
- CHANGELOG entries documenting features and structure for all modules
- Terraform variable configurations for Kubernetes execution, provisioner selection, and HSF plugin customization
- Example terraform.tfvars and .gitignore for repository management
- PR template and CODEOWNERS configuration for workflow management

### Key Features

- Support for Terraform and OpenTofu provisioners with configurable versioning
- Kubernetes execution environment support (self-hosted or Harness Cloud)
- Configurable HSF plugin images with SSL validation options
- Harness IDP integration for automated resource management
- Repository mirroring and automated token rotation scheduling
- Support for custom template library repositories

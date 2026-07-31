# Changelog

All notable changes to the Harness Solutions Factory module are documented in this file.

## v2.5.2

### Added
- Solutions Factory workspace resource (`hsf_ws_solutions_factory.tf`) for centralized IACM configuration and terraform variable management
- Local variable extraction of terraform variables from Solutions Factory workspace for factory_floor module configuration

### Updated
- Refactored factory_floor module invocation to receive variables from Solutions Factory workspace terraform variables instead of direct input parameters
- Updated default HSF source branch from v2.5.1 to v2.5.2
- Changed Solutions Factory workspace reference from data source to managed resource for improved configuration control
- Modified hsf_hub_mgr workspace to reference managed Solutions Factory workspace instead of data source
- Updated Deploy Factory Floor pipeline to source git repository configuration from workspace properties instead of locals
- Removed unnecessary dependency declaration from enable_hsf_mini_factory platform variable

### Removed
- Data source for Solutions Factory workspace (now managed as importable resource)

## v2.5.1

### Added
- New example Terraform variables file (`terraform.tfvars.example`) with comprehensive configuration documentation
- HSF Token Rotation plugin variable for automated API token management

### Changed
- Updated Harness provider version requirement from >= 0.24 to >= 0.41
- Updated default provisioner version from 1.10.0 to 1.12.3
- Updated default HSF plugin image versions:
  - Script Manager: v1.13.0 → v1.14.0
  - IACM Workspace Manager: v1.7.6 → v1.7.7
  - IDP Resource Manager: v1.3.5 → v1.3.6
- Added explicit Terraform version requirement (>= 1.10.0, < 2.0.0)
- Added explicit time provider version constraint (~> 0.14.0)
- Fixed enable_hsf_mini_factory variable type from string to bool

### Fixed
- Fixed typo in output name: `bulk_managment_pipeline_id` to `bulk_management_pipeline_id`
- Removed org_id assignment from enable_hsf_mini_factory platform variable

## v2.5.0

### Added
- Enhanced README documentation with Quick Start guide and comprehensive variable organization
- Core workspace management pipelines and step group templates
- Day-2 operational pipelines: Provision, Plan and Validate, Drift Analysis, and Teardown
- IDP resource management and integration pipelines
- Base factory projects: Image Factory and Delegate Management
- Project variables for Harness API connectivity
- RBAC controls and resource group configurations
- Support for HSF Hub deployment
- Support for Mini Factory configuration
- Configurable provisioner selection (Terraform or OpenTofu)
- HSF plugin image configuration with SSL validation options
- IDP integration support

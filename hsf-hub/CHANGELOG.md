# Changelog

All notable changes to the Harness Solutions Factory Hub module are documented in this file.

## v2.5.1

### Changed
- Updated Harness provider version requirement from >=0.31 to >=0.41
- Updated time provider version from ~>0.9.1 to ~>0.14.0
- Added explicit Terraform version requirement (>=1.10.0, <2.0.0)
- Refactored Solutions Factory defaults extraction in locals.tf with safety check for empty results
- Changed default value for `should_use_harness_idp` from string "true" to boolean `true`
- Added documentation comments for `content_library_connector` and `content_library_repo` variables
- Enhanced `content_library` variable description with guidance about required local copy of template library
- Removed verbose documentation comments from HSF_Admins and HSF_Users group templates
- Removed commented-out LandingZoneOperator role bindings from HSF_Users group template

### Removed
- Removed legacy Makefile build configuration file
- Removed example role definitions:
  - FF_Manager (Feature Flag Manager)
  - FF_User (Feature Flag User)
  - Policy_Manager (Governance Policy Manager)
  - Release_Manager
- Removed role permission sets (no longer referenced):
  - Administrative Functions
  - AI/SRE Operations
  - Artifact Registry Management
  - Chaos Engineering
  - Cloud Development Environments
  - Continuous Error Tracking
  - Database DevOps
  - Developer Portal
  - Discovery Tools
  - Environments Management
  - Feature Flag Management
  - GitOps
  - Governance and Policy
  - Harness Code Repository
  - Infrastructure as Code
  - Input Sets
  - Monitoring and Observability
  - Pipeline Management
  - Security Orchestration
  - Service Reliability Engineering
  - Services Management
  - Shared Resources Access
  - Software Engineering Insights
  - Supply Chain Security
  - Webhooks Management

## v2.5.0

### Added
- Complete HSF Hub module implementation for API-driven workspace provisioning
- Enhanced README documentation with Quick Start guide and comprehensive details
- Hub project creation with Shared_Resource_Access and LandingZoneOperator roles
- RBAC group bindings for HSF_Admins and HSF_Users
- Policies and policy sets for hub access control
- Hub-specific operational pipelines loaded from content library
- Resource groups for access scoping and control
- Role definitions with permission sets including:
  - Administrative Functions
  - AI/SRE Operations
  - Artifact Registry Management
  - Chaos Engineering
  - Cloud Development Environments
  - Continuous Error Tracking
  - Database DevOps
  - Developer Portal
  - Discovery Tools
  - Environments Management
  - Feature Flag Management
  - GitOps
  - Governance and Policy
  - Infrastructure as Code
  - Input Sets
  - Monitoring and Observability
  - Pipeline Management
  - Security Orchestration
  - Service Reliability Engineering
  - Services Management
  - Shared Resources Access
  - Software Engineering Insights
  - Supply Chain Security
  - Webhooks Management
- Content library integration for dynamic pipeline registration
- Workspace management targeting for hub-deployed resources

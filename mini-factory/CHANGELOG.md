# Changelog

All notable changes to the Harness Solutions Factory Mini Factory module are documented in this file.

## v2.5.1

### Changed
- Updated Harness provider version requirement from >= 0.31 to >= 0.41
- Updated time provider version from ~> 0.9.1 to ~> 0.14.0
- Added explicit Terraform version requirement (>= 1.10.0, < 2.0.0)
- Changed project name format from raw project ID to human-readable format with spaces
- Fixed Factory Floor module source path from ../factory_floor to ../factory-floor

### Removed
- Removed legacy Makefile build configuration file

## v2.5.0

### Added
- Complete Mini Factory module implementation with organizational project creation
- Enhanced README documentation with Quick Start guide and comprehensive variable descriptions
- Terraform configuration and provider setup for Mini Factory deployment
- Local configuration variables for project and organization management
- Terraform variable definitions for connection and project configuration
- Example terraform.tfvars file for easy deployment setup
- Integration with Factory Floor module for distributed workspace management

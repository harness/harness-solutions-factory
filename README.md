# Harness Solutions Factory v2

**Harness Solutions Factory (HSF)** is a scalable automation framework designed to help organizations rapidly deploy and manage Harness resources through self-service workflows, governance, and best practices, all out of the box. Whether you're enabling new teams, setting up golden templates, or driving adoption of Harness at scale, HSF provides a repeatable, governed foundation to help you get started faster and stay standardized across your organization.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [Core Components](#core-components)
- [Requirements](#requirements)
- [Deployment Guide](#deployment-guide)
- [Contributing](#contributing)
- [License](#license)

## Overview

HSF provides a comprehensive ecosystem of Terraform modules that progressively build out your Harness platform infrastructure. Starting from foundational setup through advanced distributed operations, each module in HSF addresses specific stages of your Harness adoption journey.

The framework follows a **modular, progressive deployment approach**:

1. **Pilot Light** — Bootstrap foundational Harness resources
2. **Solutions Factory** — Deploy core workspace management infrastructure
3. **Factory Floor** — Add operational pipelines to any project
4. **Mini Factory** — Distribute factory capabilities across organizations
5. **HSF Hub** — Enable API-driven provisioning for service portals
6. **HSF Core Manager** — Placeholder for centralized resource management

## Quick Start

### Prerequisites

- Valid Harness Account and API Key (Account-level Admin)
- [OpenTofu](https://opentofu.org/) or [Terraform](https://developer.hashicorp.com/terraform/install) installed locally
- This repository cloned to your local machine
- An IDE or text editor

### Minimal Setup

The fastest way to get started:

```bash
# 1. Clone and navigate to Pilot Light
git clone https://github.com/harness/harness-solutions-factory-v2.git
cd harness-solutions-factory-v2/pilot-light

# 2. Configure your credentials
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Harness account details

# 3. Deploy
tofu init && tofu apply

# 4. Copy local state to the remote IACM workspace
tofu init
```

After Pilot Light completes, follow the output instructions to proceed with subsequent modules.

## Repository Structure

```
harness-solutions-factory-v2/
├── README.md                    # This file - overview and navigation
├── pilot-light/                 # Foundation module (start here)
├── solutions-factory/           # Core workspace management
├── factory-floor/               # Operational pipelines (reusable module)
├── mini-factory/                # Distributed factory pattern
├── hsf-hub/                      # API-driven provisioning
├── hsf-core-mgr/                # Centralized management (placeholder)
├── CONTRIBUTING.md              # Contributor guidelines
└── LICENSE                       # Business Source License 1.1
```

## Core Components

### 🚀 [Pilot Light](./pilot-light/README.md)

**Entry point for HSF deployment**

Sets up the minimal infrastructure needed to bootstrap the Solutions Factory:
- Organization and project creation
- Service account with admin permissions
- IACM workspaces for state management
- Repository connectors and DockerHub integration
- Scheduled repository mirroring and token rotation

**Start here** if this is your first HSF deployment.

→ [Full Pilot Light Documentation](./pilot-light/README.md)

---

### 🏭 [Solutions Factory](./solutions-factory/README.md)

**Centralized workspace management hub**

Deploys the main HSF infrastructure for managing IACM workspaces at scale:
- Core workspace management pipelines
- Day-2 operational pipelines (provisioning, validation, drift analysis, teardown)
- IDP resource management and integration workflows
- Central project with shared templates and connectors
- Infrastructure projects for Images and Delegate management
- RBAC controls and resource groups

**Deploy after Pilot Light** to establish your primary workspace management infrastructure.

→ [Full Solutions Factory Documentation](./solutions-factory/README.md)

---

### 🔧 [Factory Floor](./factory-floor/README.md)

**Reusable operational pipeline suite**

A modular factory pattern that can be deployed to multiple projects for workspace lifecycle management:
- Day-Zero through Day-180 IACM workspace operations
- Create, provision, validate, drift-check, and teardown pipelines
- Project-level RBAC and resource groups
- Bulk workspace management with tag-based filtering
- Optional IDP integration for automated drift detection

**Use to extend HSF pipelines to other projects** after Solutions Factory is active.

→ [Full Factory Floor Documentation](./factory-floor/README.md)

---

### 🌐 [Mini Factory](./mini-factory/README.md)

**Distributed workspace management across organizations**

Enables organizational-scoped factory patterns for multi-tenant scenarios:
- Creates a Factory Floor per organization
- Isolates workspace management within organizational boundaries
- Maintains centralized governance while enabling local control

**Deploy when you need workspace management in multiple organizations** with local isolation.

→ [Full Mini Factory Documentation](./mini-factory/README.md)

---

### 🔗 [HSF Hub](./hsf-hub/README.md)

**API-driven provisioning for service portals**

Brings HSF workspace workflows to external service portals (Jira, ServiceNow, Backstage, etc.):
- Centralized Hub project with API-triggered pipelines
- HTTP endpoints for third-party integration
- Independent pipelines (no IDP required)
- Seamless integration with existing service catalogs

**Deploy when you need external system integration** with HSF workspace provisioning.

→ [Full HSF Hub Documentation](./hsf-hub/README.md)

---

### 📋 [HSF Core Manager](./hsf-core-mgr/README.md)

**Reserved for centralized resource management**

Currently a placeholder module for future Core Manager workspace functionality:
- Reserved for centralized policy and resource management
- May be provisioned when IDP is disabled in Factory Floor

**This module does not currently provision resources.**

→ [Full HSF Core Manager Documentation](./hsf-core-mgr/README.md)

---

## Requirements

### Mandatory

- **Harness Account** with Admin-level API key
- **Harness Account Number** for authentication
- **OpenTofu ≥ 1.6** or **Terraform ≥ 1.0** installed locally
- **Git access** to this repository

### Optional (for Kubernetes execution)

- Kubernetes connector configured in Harness
- Kubernetes cluster with namespace access
- Harness Delegate deployed in the target cluster
- Custom provisioner images (if overriding defaults)

## Deployment Guide

### Recommended Deployment Order

1. **[Pilot Light](./pilot-light/README.md)** (15-30 min)
   - Sets up foundational infrastructure
   - Creates organization, project, and connectors
   - Outputs instructions for next steps

2. **[Solutions Factory](./solutions-factory/README.md)** (10-20 min)
   - Deploys core workspace management
   - Creates operational pipelines
   - Integrates with Pilot Light resources

3. **Optional: [Factory Floor](./factory-floor/README.md)** (5-15 min per project)
   - Deploy to individual projects needing workspace management
   - Reuse across multiple projects
   - No organizational scope restrictions

4. **Optional: [Mini Factory](./mini-factory/README.md)** (5-15 min per org)
   - Deploy per-organization factory patterns
   - Isolate workspace management by organization

5. **Optional: [HSF Hub](./hsf-hub/README.md)** (10-20 min)
   - Enable external service portal integration
   - Set up API endpoints for third-party systems

### Configuration

Each module requires a `terraform.tfvars` file:

```bash
# Navigate to module directory
cd <module-directory>

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your environment values
editor terraform.tfvars
```

See individual module READMEs for required and optional variables.

### State Management

After initial deployment:

```bash
# For Pilot Light (recommended)
tofu init  # Push state to IACM workspace for centralized management
```

Other modules can store state locally or push to a remote backend.

## Key Features

✅ **Progressive Deployment** — Start simple, expand as needed
✅ **Modular Design** — Use components independently or together
✅ **RBAC & Governance** — Built-in access controls and policies
✅ **Day-2 Operations** — Comprehensive workspace lifecycle management
✅ **Multi-tenant Support** — Organizational isolation with Mini Factory
✅ **External Integration** — Service portal support via HSF Hub
✅ **IDP Ready** — Optional Harness IDP integration for automation
✅ **Self-Hosted or Cloud** — Kubernetes or Harness Cloud execution

## Troubleshooting

### General Issues

- **Provider errors**: Ensure Harness credentials are set correctly (variables or env vars)
- **Resource conflicts**: Verify no resources exist with same identifiers in target org/project
- **Permission errors**: Confirm API key has Account Admin permissions

### Module-Specific Issues

Refer to the troubleshooting section in each module's README:

- [Pilot Light Troubleshooting](./pilot-light/README.md#troubleshooting)
- [Solutions Factory Troubleshooting](./solutions-factory/README.md#troubleshooting)
- [Factory Floor Troubleshooting](./factory-floor/README.md#troubleshooting)
- [Mini Factory Troubleshooting](./mini-factory/README.md#troubleshooting)
- [HSF Hub Troubleshooting](./hsf-hub/README.md#troubleshooting)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for:

- Code style guidelines
- Contribution process
- Testing requirements
- Pull request procedures

## Support

For issues, questions, or feature requests:

- **Documentation**: See module-specific READMEs
- **Issues**: Open an issue on GitHub
- **Discussions**: Start a discussion for questions
- **Contact**: Reach out to the Harness team

## Authors

Module is maintained by **Harness, Inc**

## License

Business Source License 1.1 — See [LICENSE](./LICENSE) for full details.

---

## Quick Links

| Module | Purpose | Time | Status |
|--------|---------|------|--------|
| [Pilot Light](./pilot-light/README.md) | Foundation | 15-30 min | ✅ Stable |
| [Solutions Factory](./solutions-factory/README.md) | Core Hub | 10-20 min | ✅ Stable |
| [Factory Floor](./factory-floor/README.md) | Operations | 5-15 min | ✅ Stable |
| [Mini Factory](./mini-factory/README.md) | Distributed | 5-15 min | ✅ Stable |
| [HSF Hub](./hsf-hub/README.md) | Integration | 10-20 min | ✅ Stable |
| [HSF Core Manager](./hsf-core-mgr/README.md) | Reserved | — | 🔄 Planned |

---

**Ready to get started? Head to [Pilot Light](./pilot-light/README.md)!**

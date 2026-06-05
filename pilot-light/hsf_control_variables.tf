// Store Harness Platform endpoint URL as workspace variable
resource "harness_platform_variables" "solutions_factory_endpoint" {
  identifier  = "solutions_factory_endpoint"
  name        = "Harness Platform URL"
  type        = "String"
  description = join("\n", local.common_tags_tuple)
  spec {
    value_type  = "FIXED"
    fixed_value = replace(var.harness_platform_url, "/gateway", "")
  }
}

// Store Solutions Factory organization ID as workspace variable
resource "harness_platform_variables" "solutions_factory_org" {
  identifier  = "solutions_factory_org"
  name        = "Solutions Factory Organization"
  type        = "String"
  description = join("\n", local.common_tags_tuple)
  spec {
    value_type  = "FIXED"
    fixed_value = harness_platform_organization.factories.id
  }
}

// Store Solutions Factory project ID as workspace variable
resource "harness_platform_variables" "solutions_factory_project" {
  identifier  = "solutions_factory_project"
  name        = "Solutions Factory Project"
  type        = "String"
  description = join("\n", local.common_tags_tuple)
  spec {
    value_type  = "FIXED"
    fixed_value = harness_platform_project.solutions.id
  }
}

// Store Solutions Factory repository connector reference as workspace variable
resource "harness_platform_variables" "solutions_factory_connector" {
  lifecycle {
    ignore_changes = [spec.0.fixed_value]
  }

  identifier  = "harness_solutions_factory_connector"
  name        = "Harness Solutions Factory Connector"
  org_id      = harness_platform_organization.factories.id
  type        = "String"
  description = "Repository connector for Solutions Factory IACM workspaces"
  spec {
    value_type  = "FIXED"
    fixed_value = local.harness_solutions_factory_repo_connector
  }
}

// Store Solutions Factory repository name as workspace variable
resource "harness_platform_variables" "solutions_factory_repo" {
  lifecycle {
    ignore_changes = [spec.0.fixed_value]
  }

  identifier  = "harness_solutions_factory_repo"
  name        = "Harness Solutions Factory Repo"
  org_id      = harness_platform_organization.factories.id
  type        = "String"
  description = "Repository name for Solutions Factory IACM workspaces"
  spec {
    value_type  = "FIXED"
    fixed_value = local.harness_solutions_factory_repo
  }
}

// Store template library repository connector reference as workspace variable
resource "harness_platform_variables" "custom_template_library_connector" {
  lifecycle {
    ignore_changes = [spec.0.fixed_value]
  }

  identifier  = "custom_template_library_connector"
  name        = "Custom Template Library Connector"
  type        = "String"
  description = "Repository connector for custom template library"
  spec {
    value_type  = "FIXED"
    fixed_value = local.harness_template_library_repo_connector
  }
}

// Store template library repository name as workspace variable
resource "harness_platform_variables" "custom_template_library_repo" {
  lifecycle {
    ignore_changes = [spec.0.fixed_value]
  }

  identifier  = "custom_template_library_repo"
  name        = "Custom Template Library Repo"
  type        = "String"
  description = "Repository name for custom template library"
  spec {
    value_type  = "FIXED"
    fixed_value = local.harness_template_library_repo
  }
}

// Store template library SCM fetch type as workspace variable
resource "harness_platform_variables" "custom_template_library_fetch_type" {
  lifecycle {
    ignore_changes = [spec.0.fixed_value]
  }

  identifier  = "custom_template_library_fetch_type"
  name        = "Custom Template Library Fetch Type"
  type        = "String"
  description = "SCM fetch type for template library (branch, tag, or sha)"
  spec {
    value_type  = "FIXED"
    fixed_value = local.harness_template_library_fetch_type
  }
}

// Store template library SCM source reference as workspace variable
resource "harness_platform_variables" "custom_template_library_fetch_key" {
  lifecycle {
    ignore_changes = [spec.0.fixed_value]
  }

  identifier  = "custom_template_library_fetch_key"
  name        = "Custom Template Library Fetch Key"
  type        = "String"
  description = "SCM source reference (branch, tag, or commit SHA) for template library"
  spec {
    value_type  = "FIXED"
    fixed_value = local.harness_template_library_fetch_key
  }
}

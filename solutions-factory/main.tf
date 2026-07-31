// Fetch the selected Harness organization
data "harness_platform_organization" "selected" {
  identifier = var.organization_id
}

// Fetch the selected Harness project within the organization
data "harness_platform_project" "selected" {
  identifier = var.project_id
  org_id     = data.harness_platform_organization.selected.id
}

// Fetch the SCM connector for the custom template library
data "harness_platform_variables" "custom_template_library_connector" {
  identifier = "custom_template_library_connector"
}

// Fetch the repository name for the custom template library
data "harness_platform_variables" "custom_template_library_repo" {
  identifier = "custom_template_library_repo"
}

// Fetch the SCM fetch type (branch, tag, or sha) for the custom template library
data "harness_platform_variables" "custom_template_library_fetch_type" {
  identifier = "custom_template_library_fetch_type"
}

// Fetch the SCM reference (branch name, tag, or commit sha) for the custom template library
data "harness_platform_variables" "custom_template_library_fetch_key" {
  identifier = "custom_template_library_fetch_key"
}

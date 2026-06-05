locals {
  // Construct direct URL to HSF Hub project overview page
  project_url = join("/",
    [
      trimsuffix(replace(var.harness_platform_url, "gateway", "ng"), "/"),
      "account",
      var.harness_platform_account,
      "all/orgs",
      data.harness_platform_organization.selected.id,
      "projects",
      data.harness_platform_project.selected.id,
      "overview"
    ]
  )
}

// Organization identifier where HSF Hub is deployed
output "organization_identifier" {
  description = "Organization Identifier"
  value       = data.harness_platform_organization.selected.identifier
}

// HSF Hub project identifier
output "project_identifier" {
  description = "Project Identifier"
  value       = data.harness_platform_project.selected.identifier
}

// Direct URL to HSF Hub project
output "project_url" {
  description = "HSF Hub project overview URL"
  value       = local.project_url
}

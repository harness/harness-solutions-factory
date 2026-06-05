// Deployment status indicator
output "success" {
  description = "Pilot-Light deployment completed successfully"
  value       = true
}

// Direct URL to Pilot-Light workspace resources
output "pilot_light_workspace" {
  description = "Pilot-Light workspace resources URL"
  value = join("/",
    [
      replace(trimsuffix(var.harness_platform_url, "/"), "/gateway", ""),
      "ng/account",
      var.harness_platform_account,
      "all/iacm/orgs",
      harness_platform_organization.factories.id,
      "projects",
      harness_platform_project.solutions.id,
      "workspaces",
      harness_platform_workspace.pilot_light.id,
      "resources"
    ]
  )
}

// Direct URL to Solutions Factory workspace resources
output "solutions_factory_workspace" {
  description = "Solutions Factory workspace resources URL"
  value = join("/",
    [
      replace(trimsuffix(var.harness_platform_url, "/"), "/gateway", ""),
      "ng/account",
      var.harness_platform_account,
      "all/iacm/orgs",
      harness_platform_organization.factories.id,
      "projects",
      harness_platform_project.solutions.id,
      "workspaces",
      harness_platform_workspace.solutions_factory.id,
      "resources"
    ]
  )
}

// Direct URL to deployment pipelines
output "pipelines" {
  description = "Solutions Factory pipelines URL"
  value = join("/",
    [
      replace(trimsuffix(var.harness_platform_url, "/"), "/gateway", ""),
      "ng/account",
      var.harness_platform_account,
      "all/orgs",
      harness_platform_organization.factories.id,
      "projects",
      harness_platform_project.solutions.id,
      "pipelines"
    ]
  )
}

// HSF Timer Configurations

// Wait for new project to fully initialize (avoids race condition)
resource "time_sleep" "project_setup" {
  depends_on = [
    harness_platform_project.solutions
  ]

  create_duration = "15s"
}

// Allow eventual consistency for API propagation before proceeding with resources
resource "time_sleep" "core_resources" {
  depends_on = [
    time_sleep.project_setup,
    harness_platform_connector_docker.hsf,
    harness_platform_secret_text.harness_platform_key,
    harness_platform_connector_git.hsf_official
  ]

  create_duration  = "5s"
  destroy_duration = "15s"
}

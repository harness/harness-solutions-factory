// DockerHub connector for pulling HSF plugin images in pipelines
resource "harness_platform_connector_docker" "hsf" {
  lifecycle {
    ignore_changes = [
      execute_on_delegate,
      credentials
    ]
  }
  identifier  = "hsf_dockerhub_connector"
  name        = "HSF Dockerhub Connector"
  description = "DockerHub connector used by HSF to pull plugin images for pipelines"
  org_id      = harness_platform_organization.factories.id
  tags        = local.common_tags_tuple

  type                = "DockerHub"
  url                 = "https://index.docker.io/v2/"
  execute_on_delegate = false
}

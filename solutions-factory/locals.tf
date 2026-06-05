locals {
  // Standard tags applied to all managed resources
  required_tags = {
    created_by : "Terraform"
    harnessSolutionsFactory : "true"
  }

  common_tags = local.required_tags

  // Convert tags from map to list format (Harness API requirement)
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  // Kubernetes infrastructure configuration for pipeline execution stages
  k8s_setup = {
    KUBERNETES_CONNECTOR : var.kubernetes_connector
    KUBERNETES_NAMESPACE : var.kubernetes_namespace
    KUBERNETES_SERVICEACCOUNT : (var.kubernetes_serviceaccount != "skipped" ? var.kubernetes_serviceaccount : "skipped")
    KUBERNETES_OVERRIDE_RUNAS : (var.kubernetes_override_run_as_user != "skipped" ? tonumber(var.kubernetes_override_run_as_user) : "skipped")
    KUBERNETES_NODESELECTORS : (
      length(var.kubernetes_node_selectors) == 0
      ?
      "skipped"
      :
      yamlencode(var.kubernetes_node_selectors)
    )
    KUBERNETES_IMAGE_CONNECTOR : var.kubernetes_override_image_connector
  }

  // Pipeline infrastructure template for IACM stages
  IACM_STAGE_INFRASTRUCTURE = templatefile(
    "${path.module}/templates/pipelines/snippets/iacm_infrastructure.yaml",
    local.k8s_setup
  )

  // Pipeline infrastructure template for IDP stages
  IDP_STAGE_INFRASTRUCTURE = templatefile(
    "${path.module}/templates/pipelines/snippets/idp_infrastructure.yaml",
    local.k8s_setup
  )

  // Solutions Factory repository connector configuration
  harness_solutions_factory_repo_connector = (
    var.hsf_source_connector != "skipped"
    ?
    var.hsf_source_connector
    :
    "org.Harness_Solutions_Factory_Repo___Official"
  )
  harness_solutions_factory_repo = var.hsf_source_repository
  harness_solutions_factory_type = var.hsf_source_fetch_type
  harness_solutions_factory_key  = var.hsf_source_branch

  // Template library repository connector configuration
  harness_template_library_repo_connector = (
    var.git_connector_ref != "skipped"
    ?
    var.git_connector_ref
    :
    data.harness_platform_variables.custom_template_library_connector.spec.0.fixed_value
  )
  harness_template_library_repo_name = (
    var.git_repository_name != "skipped"
    ?
    var.git_repository_name
    :
    data.harness_platform_variables.custom_template_library_repo.spec.0.fixed_value
  )

  harness_template_library_type = (
    var.git_repository_fetch_type != "skipped"
    ?
    var.git_repository_fetch_type
    :
    data.harness_platform_variables.custom_template_library_fetch_type.spec.0.fixed_value
  )
  harness_template_library_key = (
    var.git_repository_branch != "skipped"
    ?
    var.git_repository_branch
    :
    data.harness_platform_variables.custom_template_library_fetch_key.spec.0.fixed_value
  )
}

locals {
  // Required tags for all managed resources
  required_tags = {
    created_by : "Terraform"
    harnessSolutionsFactory : "true"
    managedResource : "true"
  }

  common_tags = local.required_tags

  // Convert tags map to list format required by Harness resource parameters
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]
  fmt_account_url   = replace(trimsuffix(var.harness_platform_url, "/"), "/gateway", "")

  // Values to treat as absent/unset in conditionals
  ignored_args = [
    null,
    "skipped"
  ]

  // SCM Source Configuration for Solutions Factory
  harness_solutions_factory_repo = var.hsf_source_repository

  // Use custom connector if provided, otherwise default to official repository connector
  harness_solutions_factory_repo_connector = (
    var.hsf_source_connector != "skipped"
    ?
    var.hsf_source_connector
    :
    "org.${harness_platform_connector_git.hsf_official.0.id}"
  )

  // Conditionally set branch reference based on fetch type
  harness_solutions_factory_repo_branch = (
    lower(var.hsf_source_fetch_type) == "branch"
    ?
    var.hsf_source_branch
    :
    null
  )

  // Conditionally set tag reference based on fetch type
  harness_solutions_factory_repo_tag = (
    lower(var.hsf_source_fetch_type) == "tag"
    ?
    var.hsf_source_branch
    :
    null
  )

  // Conditionally set SHA reference based on fetch type
  harness_solutions_factory_repo_sha = (
    lower(var.hsf_source_fetch_type) == "sha"
    ?
    var.hsf_source_branch
    :
    null
  )

  // Template Library Configuration
  harness_template_library_repo_connector = (
    var.should_setup_custom_tpl
    ?
    "org.${harness_platform_connector_git.custom_tpl.0.id}"
    :
    local.harness_solutions_factory_repo_connector
  )
  harness_template_library_repo = (
    var.should_setup_custom_tpl
    ?
    harness_platform_repo.custom_tpl.0.id
    :
    "harness-template-library"
  )
  harness_template_library_fetch_type = "branch"
  harness_template_library_fetch_key  = "main"

  // Account management API key secret reference
  account_management_key = "org.${harness_platform_secret_text.harness_platform_key.id}"

  // Kubernetes configuration parameters (conditionally set based on connector existence)
  use_k8s = (
    var.kubernetes_connector != null
    ?
    [
      { name = "kubernetes_connector", value = var.kubernetes_connector },
      { name = "kubernetes_namespace", value = var.kubernetes_namespace },
      { name = "kubernetes_serviceaccount", value = var.kubernetes_serviceaccount },
      { name = "kubernetes_node_selectors", value = jsonencode(var.kubernetes_node_selectors) },
      { name = "kubernetes_override_run_as_user", value = (
        var.kubernetes_override_run_as_user != "skipped"
        ?
        tonumber(var.kubernetes_override_run_as_user)
        :
        "skipped"
      ) }
    ]
    :
    []
  )

  // Custom container image override parameters
  use_custom_image = (
    var.kubernetes_override_image_name != null
    ?
    [
      { name = "kubernetes_override_image_name", value = var.kubernetes_override_image_name }
    ]
    :
    []
  )

  // Custom image registry connector parameters
  use_custom_image_connector = (
    var.kubernetes_override_image_connector != null
    ?
    [
      { name = "kubernetes_override_image_connector", value = var.kubernetes_override_image_connector }
    ]
    :
    []
  )

  // Kubernetes setup configuration object for workspace variable storage
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
}

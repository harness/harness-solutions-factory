locals {
  // Standard tags applied to all managed resources
  required_tags = {
    created_by : "Terraform"
    harnessSolutionsFactory : "true"
    managedResource : "true"
    pipeline_type : "iacm"
    factory_floor : "true"
  }

  common_tags = local.required_tags

  // Convert tags from map to list format (Harness API requirement)
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  // Construct connector identifier prefix based on resource hierarchy
  // Returns "" for project-scoped, "org." for org-scoped, "account." for account-scoped
  tier_handler = (
    var.project_id != null
    ?
    ""
    :
    var.organization_id != null
    ?
    "org."
    :
    "account."
  )

  // Gather Terraform variables from Solutions Factory workspace as defaults
  solutions_factory_ws_defaults = flatten([{
    for elem in data.harness_platform_workspace.solutions_factory.terraform_variable :
    (elem.key) => (elem.value)
    }
  ])

  solutions_factory_defaults = length(local.solutions_factory_ws_defaults) > 0 ? local.solutions_factory_ws_defaults[0] : {}

  // Merge provided variables with defaults from Solutions Factory workspace
  factory_floor_variables = {
    existing_harness_platform_key_ref : (
      var.existing_harness_platform_key_ref == null
      ?
      lookup(local.solutions_factory_defaults, "existing_harness_platform_key_ref", var.existing_harness_platform_key_ref)
      :
      var.existing_harness_platform_key_ref
    )

    git_repository_branch : (
      var.git_repository_branch == null
      ?
      lookup(local.solutions_factory_defaults, "git_repository_branch", var.git_repository_branch)
      :
      var.git_repository_branch
    )

    git_connector_ref : (
      var.git_connector_ref == null
      ?
      lookup(local.solutions_factory_defaults, "git_connector_ref", var.git_connector_ref)
      :
      var.git_connector_ref
    )

    git_repository_name : (
      var.git_repository_name == null
      ?
      lookup(local.solutions_factory_defaults, "git_repository_name", var.git_repository_name)
      :
      var.git_repository_name
    )

    kubernetes_connector : (
      var.kubernetes_connector == null
      ?
      lookup(local.solutions_factory_defaults, "kubernetes_connector", var.kubernetes_connector)
      :
      var.kubernetes_connector
    )

    kubernetes_namespace : (
      var.kubernetes_namespace == null
      ?
      lookup(local.solutions_factory_defaults, "kubernetes_namespace", var.kubernetes_namespace)
      :
      var.kubernetes_namespace
    )

    kubernetes_serviceaccount : (
      var.kubernetes_serviceaccount == null
      ?
      lookup(local.solutions_factory_defaults, "kubernetes_serviceaccount", var.kubernetes_serviceaccount)
      :
      var.kubernetes_serviceaccount
    )

    kubernetes_override_run_as_user : (
      var.kubernetes_override_run_as_user == null
      ?
      lookup(local.solutions_factory_defaults, "kubernetes_override_run_as_user", var.kubernetes_override_run_as_user)
      :
      var.kubernetes_override_run_as_user
    )

    kubernetes_node_selectors : (
      var.kubernetes_node_selectors == {}
      ?
      jsondecode(lookup(local.solutions_factory_defaults, "kubernetes_node_selectors", jsonencode(var.kubernetes_node_selectors)))
      :
      var.kubernetes_node_selectors
    )

    kubernetes_override_image_connector : (
      var.kubernetes_override_image_connector == null
      ?
      lookup(local.solutions_factory_defaults, "kubernetes_override_image_connector", var.kubernetes_override_image_connector)
      :
      var.kubernetes_override_image_connector
    )

    kubernetes_override_image_name : (
      var.kubernetes_override_image_name == null
      ?
      lookup(local.solutions_factory_defaults, "kubernetes_override_image_name", var.kubernetes_override_image_name)
      :
      var.kubernetes_override_image_name
    )

    provisioner_type : (
      var.provisioner_type == null
      ?
      lookup(local.solutions_factory_defaults, "provisioner_type", var.provisioner_type)
      :
      var.provisioner_type
    )

    provisioner_version : (
      var.provisioner_version == null
      ?
      lookup(local.solutions_factory_defaults, "provisioner_version", var.provisioner_version)
      :
      var.provisioner_version
    )

    hsf_pipeline_connector_ref : (
      var.hsf_pipeline_connector_ref == null
      ?
      lookup(local.solutions_factory_defaults, "hsf_pipeline_connector_ref", var.hsf_pipeline_connector_ref)
      :
      var.hsf_pipeline_connector_ref
    )

    hsf_script_mgr_image : (
      var.hsf_script_mgr_image == null
      ?
      lookup(local.solutions_factory_defaults, "hsf_script_mgr_image", var.hsf_script_mgr_image)
      :
      var.hsf_script_mgr_image
    )

    hsf_idp_resource_mgr_image : (
      var.hsf_idp_resource_mgr_image == null
      ?
      lookup(local.solutions_factory_defaults, "hsf_idp_resource_mgr_image", var.hsf_idp_resource_mgr_image)
      :
      var.hsf_idp_resource_mgr_image
    )

    hsf_iacm_manager_plugin : (
      var.hsf_iacm_manager_plugin == null
      ?
      lookup(local.solutions_factory_defaults, "hsf_iacm_manager_plugin", var.hsf_iacm_manager_plugin)
      :
      var.hsf_iacm_manager_plugin
    )

    hsf_rotate_token_plugin : (
      var.hsf_rotate_token_plugin == null
      ?
      lookup(local.solutions_factory_defaults, "hsf_rotate_token_plugin", var.hsf_rotate_token_plugin)
      :
      var.hsf_rotate_token_plugin
    )
    hsf_iacm_manager_plugin : (
      var.hsf_iacm_manager_plugin == null
      ?
      lookup(local.solutions_factory_defaults, "hsf_iacm_manager_plugin", var.hsf_iacm_manager_plugin)
      :
      var.hsf_iacm_manager_plugin
    )

    hsf_plugin_ssl_verify_x509_strict : (
      var.hsf_plugin_ssl_verify_x509_strict == null
      ?
      lookup(local.solutions_factory_defaults, "hsf_plugin_ssl_verify_x509_strict", var.hsf_plugin_ssl_verify_x509_strict)
      :
      var.hsf_plugin_ssl_verify_x509_strict
    )

    should_use_harness_idp : (
      var.should_use_harness_idp == null
      ?
      lookup(local.solutions_factory_defaults, "should_use_harness_idp", var.should_use_harness_idp)
      :
      var.should_use_harness_idp
    )

  }

  // Track variables with null or empty values for validation
  invalid_factory_floor_variables = [for k, v in local.factory_floor_variables : k if v == null || v == ""]

  // Kubernetes infrastructure configuration for pipeline execution stages
  k8s_setup = {
    KUBERNETES_CONNECTOR : local.factory_floor_variables.kubernetes_connector
    KUBERNETES_NAMESPACE : local.factory_floor_variables.kubernetes_namespace
    KUBERNETES_SERVICEACCOUNT : (local.factory_floor_variables.kubernetes_serviceaccount != "skipped" ? local.factory_floor_variables.kubernetes_serviceaccount : "skipped")
    KUBERNETES_OVERRIDE_RUNAS : (local.factory_floor_variables.kubernetes_override_run_as_user != "skipped" ? tonumber(local.factory_floor_variables.kubernetes_override_run_as_user) : "skipped")
    KUBERNETES_NODESELECTORS : (local.factory_floor_variables.kubernetes_node_selectors != "{}" ? yamlencode(local.factory_floor_variables.kubernetes_node_selectors) : "skipped")
    KUBERNETES_IMAGE_CONNECTOR : local.factory_floor_variables.kubernetes_override_image_connector
  }

  // Pipeline infrastructure template for IACM stages
  IACM_STAGE_INFRASTRUCTURE = (
    length(local.invalid_factory_floor_variables) == 0
    ?
    templatefile(
      "${path.module}/templates/pipelines/snippets/iacm_infrastructure.yaml", local.k8s_setup
    )
    :
    ""
  )

  // Pipeline infrastructure template for IDP stages
  IDP_STAGE_INFRASTRUCTURE = (
    length(local.invalid_factory_floor_variables) == 0
    ?
    templatefile(
      "${path.module}/templates/pipelines/snippets/idp_infrastructure.yaml", local.k8s_setup
    )
    :
    ""
  )

  // HSF built-in roles plus custom roles for workspace access
  hsf_users_roles = compact(flatten(concat([
    "_idp_workflow_executor",
    "_pipeline_executor",
    ], [
    for role in harness_platform_roles.roles : [
      role.identifier
    ]
  ])))

  // Base directory for pipeline templates
  source_directory = "${path.module}/templates"
}

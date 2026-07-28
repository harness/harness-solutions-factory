locals {
  // Pilot-Light workspace identifier
  hsf_pilot_light_id = "harness_pilot_light"
}

// Create Pilot-Light workspace for bootstrap and foundational configurations
resource "harness_platform_workspace" "pilot_light" {
  depends_on = [
    time_sleep.core_resources
  ]
  lifecycle {
    ignore_changes = [
      provisioner_type,
      provisioner_version,
      provider_connector,
    ]
  }
  name                = "Harness Pilot Light"
  identifier          = local.hsf_pilot_light_id
  org_id              = harness_platform_organization.factories.id
  project_id          = harness_platform_project.solutions.id
  provisioner_type    = var.provisioner_type
  provisioner_version = var.provisioner_version

  # In this case, we will always set the original source for the HSF Pilot Light to the Official
  # repository. Since the lifecycle changes for these three parameters will be ignored, the customer
  # will be able to adjust to their needs.
  repository_connector = local.harness_solutions_factory_repo_connector
  repository           = local.harness_solutions_factory_repo
  repository_branch    = local.harness_solutions_factory_repo_branch
  repository_commit    = local.harness_solutions_factory_repo_tag
  repository_sha       = local.harness_solutions_factory_repo_sha
  #
  repository_path         = "pilot-light"
  cost_estimation_enabled = false
  tags                    = ["source:hsf_system", "type:pilot_light"]

  terraform_variable {
    key        = "hsf_source_connector"
    value      = local.harness_solutions_factory_repo_connector
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_source_repository"
    value      = local.harness_solutions_factory_repo
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_source_fetch_type"
    value      = var.hsf_source_fetch_type
    value_type = "string"
  }

  terraform_variable {
    key        = "hsf_source_branch"
    value      = var.hsf_source_branch
    value_type = "string"
  }

  dynamic "terraform_variable" {
    for_each = local.use_k8s

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }

  dynamic "terraform_variable" {
    for_each = local.use_custom_image

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }
  dynamic "terraform_variable" {
    for_each = local.use_custom_image_connector

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }

  dynamic "terraform_variable" {
    for_each = local.hsf_plugin_workspace_variables

    content {
      key        = terraform_variable.value.name
      value      = terraform_variable.value.value
      value_type = "string"
    }
  }

  terraform_variable {
    key        = "should_rotate_on_schedule"
    value      = var.should_rotate_on_schedule
    value_type = "string"
  }

  terraform_variable {
    key        = "rotation_schedule"
    value      = var.rotation_schedule
    value_type = "string"
  }

  terraform_variable {
    key        = "initial_admin_user"
    value      = var.initial_admin_user
    value_type = "string"
  }

  terraform_variable {
    key        = "provisioner_type"
    value      = var.provisioner_type
    value_type = "string"
  }

  terraform_variable {
    key        = "provisioner_version"
    value      = var.provisioner_version
    value_type = "string"
  }

  terraform_variable {
    key        = "should_use_harness_idp"
    value      = var.should_use_harness_idp
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_ENDPOINT"
    value      = var.harness_platform_url
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_ACCOUNT_ID"
    value      = var.harness_platform_account
    value_type = "string"
  }

  environment_variable {
    key        = "HARNESS_PLATFORM_API_KEY"
    value      = local.account_management_key
    value_type = "secret"
  }

  environment_variable {
    key        = "TF_VAR_harness_platform_url"
    value      = var.harness_platform_url
    value_type = "string"
  }

  environment_variable {
    key        = "TF_VAR_harness_platform_account"
    value      = var.harness_platform_account
    value_type = "string"
  }

  environment_variable {
    key        = "TF_VAR_harness_platform_key"
    value      = local.account_management_key
    value_type = "secret"
  }
  environment_variable {
    key        = "PLUGIN_HSF_ENABLED"
    value      = "true"
    value_type = "string"
  }

  default_pipelines = {
    "destroy" = harness_platform_pipeline.pilot_light.id
    "drift"   = harness_platform_pipeline.pilot_light.id
    "plan"    = harness_platform_pipeline.pilot_light.id
    "apply"   = harness_platform_pipeline.pilot_light.id
  }

}

resource "harness_platform_pipeline" "pilot_light" {
  identifier  = "Manage_Pilot_Light"
  name        = "Manage Pilot Light"
  org_id      = harness_platform_organization.factories.id
  project_id  = harness_platform_project.solutions.id
  description = "Pipeline used to manage the HSF Pilot Light workspace. Used during upgrades and configuration changes"

  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_Manange_Pilot_Light.yaml",
    {
      PIPELINE_IDENTIFIER : "Manage_Pilot_Light"
      PIPELINE_NAME : "Manage Pilot Light"
      ORGANIZATION_ID : harness_platform_organization.factories.id
      PROJECT_ID : harness_platform_project.solutions.id
      DESCRIPTION : "Pipeline used to manage the HSF Pilot Light workspace. Used during upgrades and configuration changes"
      WORKSPACE_NAME : local.hsf_pilot_light_id
      KUBERNETES_IMAGE_NAME : var.kubernetes_override_image_name
      STAGE_INFRASTRUCTURE : templatefile(
        "${path.module}/templates/pipelines/snippets/iacm_infrastructure.yaml",
        local.k8s_setup
      )

      TAGS : yamlencode(merge(local.common_tags, { pipeline_type : "hsf" }))
    }
  )
  tags = flatten([
    local.common_tags_tuple,
    ["pipeline_type:hsf"]
  ])
}

resource "local_sensitive_file" "backend_tf" {
  count      = var.store_backend ? 1 : 0
  depends_on = [harness_platform_workspace.pilot_light]
  filename   = "${path.module}/backend.tf"
  content = templatefile(
    "${path.module}/templates/iacm_backend.tfpl",
    {
      WORKSPACE = join("/",
        [
          trimsuffix(var.harness_platform_url, "/"),
          "iacm/api/orgs",
          harness_platform_organization.factories.id,
          "projects",
          harness_platform_project.solutions.id,
          "workspaces",
          harness_platform_workspace.pilot_light.id
        ]
      )
      HARNESS_ACCOUNT = var.harness_platform_account
      HARNESS_APIKEY  = var.harness_platform_key
    }
  )
}

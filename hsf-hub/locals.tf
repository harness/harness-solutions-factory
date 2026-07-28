locals {
  // Required tags for all HSF Hub resources
  required_tags = {
    created_by : "Terraform"
    harnessSolutionsFactory : "true"
  }

  // Merge user-provided tags with required tags
  common_tags = merge(
    var.tags,
    local.required_tags
  )

  // Convert tags map to list format required by Harness resource parameters
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  // Generate project identifier from name if not explicitly provided (replaces spaces and dashes with underscores)
  fmt_identifier = (
    var.project_id == null
    ?
    replace(
      replace(
        var.project_name,
        " ",
        "_"
      ),
      "-",
      "_"
    )
    :
    var.project_id
  )

  // Path to module templates directory
  source_directory = "${path.module}/templates"

  // Normalize content library path (remove trailing slash)
  content_library = trimsuffix(var.content_library, "/")

  // Full path to registration manager YAML file
  registration_mgr = join("/", [local.content_library, var.registration_mgr])

  // Parse registration manager YAML to extract entity definitions
  registration_mgr_entities = (
    fileexists(local.registration_mgr)
    ?
    lookup(yamldecode(file(local.registration_mgr)), "entities", []) != null
    ?
    lookup(yamldecode(file(local.registration_mgr)), "entities", [])
    :
    ["INVALID-YAML-STRUCTURE"]
    :
    ["REGISTRATION-MGR-MISSING"]
  )

  // Extract Solutions Factory workspace variables for HSF defaults
  solutions_factory_ws_defaults = flatten([{
    for elem in data.harness_platform_workspace.solutions_factory.terraform_variable :
    (elem.key) => (elem.value)
    }
  ])

  solutions_factory_defaults = length(local.solutions_factory_ws_defaults) > 0 ? local.solutions_factory_ws_defaults[0] : {}

  // Check if Harness IDP should be used (from Solutions Factory defaults)
  should_use_harness_idp = lookup(local.solutions_factory_defaults, "should_use_harness_idp", true)
}

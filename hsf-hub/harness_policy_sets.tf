locals {
  // Path to policy set templates directory
  policy_sets_files_path = "${local.source_directory}/policy_sets"

  // Load all YAML policy set definition files
  policy_sets_files = fileset("${local.policy_sets_files_path}/", "*.yaml")

  // Parse policy set definitions and normalize identifiers
  policy_sets = flatten([
    for policy_file in local.policy_sets_files : [
      merge(
        yamldecode(file("${local.policy_sets_files_path}/${policy_file}")),
        {
          identifier = replace(replace(replace(policy_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(policy_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])
}

// Create Harness policy sets from YAML definitions
resource "harness_platform_policyset" "policy_sets" {
  for_each = {
    for policy_set in local.policy_sets : policy_set.name => policy_set
  }
  // Validate that required fields are present in policy set definition
  lifecycle {
    precondition {
      condition = alltrue([
        contains(keys(each.value), "identifier"),
        contains(keys(each.value), "name"),
        contains(keys(each.value), "action"),
        contains(keys(each.value), "type"),
        contains(["onrun", "onsave", "onstep"], lookup(each.value, "action", "missing-action"))
      ])
      error_message = <<EOF
      [Invalid] The following PolicySet (${each.key}) is invalid and missing one or more mandatory keys.
      - identifier
      - name
      - action
      - type

      Supported action types are (depends on Policy Set type):
      - onrun
      - onsave
      - onstep
      EOF
    }
  }
  identifier = each.value.identifier
  name       = each.value.name
  action     = each.value.action
  type       = each.value.type
  enabled    = lookup(each.value, "enabled", true)

  // Dynamically reference policies based on YAML definition
  dynamic "policy_references" {
    for_each = lookup(each.value, "policies", [])
    content {
      identifier = policy_references.value["identifier"]
      severity   = lookup(policy_references.value, "severity", "error")
    }
  }

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}

// Policy set management for grouping and applying OPA policies

// Load policy set definition files from templates directory
locals {
  policy_sets_files_path = "${local.source_directory}/policy_sets"

  policy_sets_files = fileset("${local.policy_sets_files_path}/", "*.yaml")

  // Parse YAML policy set definitions and normalize identifiers
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

// Create policy sets that group related OPA policies for enforcement
resource "harness_platform_policyset" "policy_sets" {
  depends_on = [harness_platform_policy.policies]

  for_each = {
    for policy_set in local.policy_sets : policy_set.name => policy_set
  }

  identifier = each.value.identifier
  name       = each.value.name
  org_id     = var.organization_id
  project_id = var.project_id
  action     = each.value.action
  type       = each.value.type
  enabled    = lookup(each.value, "enabled", true)

  // Validate that all referenced policies exist and required fields are present
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

      Supported action types:
      - onrun
      - onsave
      - onstep
      EOF
    }
  }

  // Add policies to policy set with severity levels
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

// Delay resource cleanup to avoid race condition when removing PolicySets
resource "time_sleep" "policy_set_setup" {
  depends_on = [
    harness_platform_policyset.policy_sets
  ]

  destroy_duration = "5s"
}

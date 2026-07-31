// OPA policy management for governance and compliance controls

// Load policy definition files from templates directory
locals {
  policies_files_path = "${local.source_directory}/policies"

  policy_files = fileset("${local.policies_files_path}/", "*.rego")

  // Parse Rego policy files and normalize names/identifiers
  policies = flatten([
    for policy_file in local.policy_files : [
      {
        identifier = replace(replace(replace(policy_file, ".rego", ""), " ", "_"), "-", "_")
        name       = replace(replace(replace(policy_file, ".rego", ""), "-", "_"), "_", " ")
        payload    = file("${local.policies_files_path}/${policy_file}")
      }
    ]
  ])
}

// Create OPA policies for workspace governance and access control
resource "harness_platform_policy" "policies" {
  for_each = {
    for policy in local.policies : policy.name => policy
  }

  identifier  = each.value.identifier
  name        = each.value.name
  description = lookup(each.value, "description", "Harness Policy managed by Solutions Factory")
  org_id      = var.organization_id
  project_id  = var.project_id
  rego        = each.value.payload

  // Ignore git-related changes managed externally
  lifecycle {
    ignore_changes = [
      git_commit_msg,
      git_connector_ref,
      git_path,
      git_repo,
      git_branch,
      git_base_branch,
      git_is_new_branch,
      git_import
    ]
  }

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}

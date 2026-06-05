locals {
  // Path to policy templates directory
  policies_files_path = "${local.source_directory}/policies"

  // Load all Rego policy files from templates
  policy_files = fileset("${local.policies_files_path}/", "*.rego")

  // Parse policy files and normalize identifiers (remove extension, replace spaces/dashes with underscores)
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

// Create Harness policies from Rego definitions
resource "harness_platform_policy" "policies" {
  // Ignore Git history and external updates
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
  for_each = {
    for policy in local.policies : policy.name => policy
  }
  identifier  = each.value.identifier
  name        = each.value.name
  description = lookup(each.value, "description", "Harness Policy managed by Solutions Factory")
  rego        = each.value.payload

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}

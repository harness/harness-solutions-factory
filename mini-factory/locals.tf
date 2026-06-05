locals {
  // Required tags for all managed resources
  required_tags = {
    created_by : "Terraform"
    harnessSolutionsFactory : "true"
    managedResource : "true"
  }

  // Merge user-provided tags with required tags
  common_tags = merge(
    var.tags,
    local.required_tags
  )

  // Convert tags map to list format required by Harness resource parameters
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]
}

// Projects for factory-specific operations

// Image Factory project for building and managing container images
resource "harness_platform_project" "images" {
  identifier = "Image_Factory"
  name       = "Image Factory"
  org_id     = data.harness_platform_organization.selected.id
  color      = "#D75E59"
  tags       = local.common_tags_tuple
}

// Delegate Management project for managing Harness delegates
resource "harness_platform_project" "delegates" {
  identifier = "Delegate_Management"
  name       = "Delegate Management"
  org_id     = data.harness_platform_organization.selected.id
  color      = "#0DAA68"
  tags       = local.common_tags_tuple
}

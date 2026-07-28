// HSF Account-level RBAC Configurations

// Create HSF Admins group for full admin access to HSF resources
resource "harness_platform_usergroup" "hsf_admins" {
  lifecycle {
    ignore_changes = [
      users,
      user_emails,
      notification_configs,
      linked_sso_id,
      linked_sso_display_name,
      linked_sso_type,
      sso_linked,
      sso_group_id,
      sso_group_name
    ]
  }
  identifier  = "HSF_Admins"
  name        = "HSF Admins"
  description = "Harness Solutions Factory Admin Group with access to all HSF resources"
  user_emails = var.initial_admin_user != "skipped" ? [var.initial_admin_user] : []
  notification_configs {
    type                    = "EMAIL"
    send_email_to_all_users = true
  }
  tags = flatten([
    local.common_tags_tuple,
    "purpose:IDP_Admin_Group"
  ])
}

# Configure organization-level permissions for the HSF Admins group that will be granted
# full admin access to manage and update the HSF installation
resource "harness_platform_role_assignments" "hsf_admins" {
  identifier                = "hsf_admins"
  org_id                    = harness_platform_organization.factories.id
  resource_group_identifier = "_all_resources_including_child_scopes"
  role_identifier           = "_organization_admin"
  principal {
    identifier  = harness_platform_usergroup.hsf_admins.id
    type        = "USER_GROUP"
    scope_level = "account"
  }
  disabled = false
  managed  = false
}

# Create new HSF Users group that will be granted full read and execute access to scoped
# pipelines in the HSF installation.
resource "harness_platform_usergroup" "hsf_users" {
  lifecycle {
    ignore_changes = [
      users,
      user_emails,
      notification_configs,
      linked_sso_id,
      linked_sso_display_name,
      linked_sso_type,
      sso_linked,
      sso_group_id,
      sso_group_name
    ]
  }
  identifier  = "HSF_Users"
  name        = "HSF Users"
  description = "Harness Solutions Factory Users with access to templates"
  user_emails = var.initial_admin_user != "skipped" ? [var.initial_admin_user] : []
  tags = flatten([
    local.common_tags_tuple,
    "purpose:IDP_Users_Group"
  ])
}

# Configure new role to set Shared Resource Access permissions for the HSF Users group to
# access organization-level resources
resource "harness_platform_roles" "shared_resource_access" {
  identifier = "Shared_Resource_Access"

  name                 = "Shared_Resource_Access"
  org_id               = harness_platform_organization.factories.id
  allowed_scope_levels = ["organization"]

  # [Optional] (Set of String) List of the permission identifiers
  #
  # Note: Full list of current and valid permissions can be found here
  # https://app.harness.io/gateway/authz/api/permissions
  # API Docs - https://apidocs.harness.io/tag/Permissions#operation/getPermissionList
  permissions = [
    "core_certificate_view",
    "core_connector_access",
    "core_connector_view",
    "core_delegate_view",
    "core_file_access",
    "core_file_view",
    "core_secret_access",
    "core_secret_view",
    "core_template_access",
    "core_template_view",
    "core_variable_view"
  ]

  tags = local.common_tags_tuple
}

# Configure organization-level permissions for the HSF Users group that will be granted
# read access to shared resources in the HSF installation
resource "harness_platform_role_assignments" "hsf_users" {
  depends_on = [harness_platform_roles.shared_resource_access]
  for_each = {
    for role in [
      harness_platform_roles.shared_resource_access.identifier
    ] : "hsf_users_${role}" => role
  }
  identifier                = each.key
  org_id                    = harness_platform_organization.factories.id
  resource_group_identifier = "_all_organization_level_resources"
  role_identifier           = each.value
  principal {
    identifier  = harness_platform_usergroup.hsf_users.id
    type        = "USER_GROUP"
    scope_level = "account"
  }
  disabled = false
  managed  = false
}

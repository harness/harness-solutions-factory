// HSF Master Credential Management

// Create master service account for HSF automation at account level
resource "harness_platform_service_account" "platform_manager" {
  count       = local.should_create_service_account ? 1 : 0
  identifier  = "harness_platform_manager"
  name        = "harness-platform-manager"
  email       = "harnessplatformmanager@service.harness.io"
  description = "Central Harness Solutions Factory Service Account"
  account_id  = var.harness_platform_account
  tags        = local.common_tags_tuple
}

// Create API key container in master service account
resource "harness_platform_apikey" "platform_manager" {
  count                        = local.should_create_service_account ? 1 : 0
  identifier                   = "platform_manager"
  name                         = "platform-manager"
  parent_id                    = harness_platform_service_account.platform_manager.0.id
  account_id                   = harness_platform_service_account.platform_manager.0.account_id
  apikey_type                  = "SERVICE_ACCOUNT"
  default_time_to_expire_token = 2592000000
  tags                         = local.common_tags_tuple
}

// Generate API token for master service account automation (expires Dec 31, 2099)
resource "harness_platform_token" "platform_manager" {
  count       = local.should_create_service_account ? 1 : 0
  identifier  = "automation"
  name        = "automation"
  parent_id   = harness_platform_apikey.platform_manager.0.parent_id
  apikey_type = harness_platform_apikey.platform_manager.0.apikey_type
  apikey_id   = harness_platform_apikey.platform_manager.0.id
  account_id  = harness_platform_apikey.platform_manager.0.account_id
  valid_to    = "4102380000000" // December 31, 2099
  tags        = local.common_tags_tuple
  lifecycle {
    ignore_changes = all
  }
}

// Grant master service account account-level admin permissions
resource "harness_platform_role_assignments" "platform_manager" {
  count                     = local.should_create_service_account ? 1 : 0
  identifier                = harness_platform_service_account.platform_manager.0.id
  resource_group_identifier = "_all_resources_including_child_scopes"
  role_identifier           = "_account_admin"
  principal {
    identifier = harness_platform_service_account.platform_manager.0.id
    type       = "SERVICE_ACCOUNT"
  }
  disabled = false
  managed  = false
}

// Store master service account token as org-level secret (unmanaged to allow customer control)
resource "harness_platform_secret_text" "harness_platform_key" {
  count       = local.should_create_service_account ? 1 : 0
  identifier  = "hsf_platform_api_key"
  name        = "HSF Platform API Key"
  description = "Harness Platform API Key"
  org_id      = harness_platform_organization.factories.id
  tags = flatten([
    local.common_tags_tuple,
    ["required_for:master_credentials"]
  ])

  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = harness_platform_token.platform_manager.0.value
  lifecycle {
    ignore_changes = all
  }
}

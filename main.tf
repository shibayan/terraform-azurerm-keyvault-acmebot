resource "azurerm_storage_account" "storage" {
  name                = "st${substr(replace(lower(var.app_base_name), "/[^a-z0-9]/", ""), 0, 22)}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.additional_tags

  account_kind                    = "Storage"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_service_plan" "serverfarm" {
  name                = "plan-${var.app_base_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.additional_tags

  os_type  = "Windows"
  sku_name = "Y1"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_log_analytics_workspace" "workspace" {
  count = var.log_analytics_workspace_id == null ? 1 : 0

  name                = "log-${var.app_base_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.additional_tags

  sku               = "PerGB2018"
  retention_in_days = 30

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_application_insights" "insights" {
  name                = "appi-${var.app_base_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.additional_tags

  application_type = "web"
  workspace_id     = coalesce(var.log_analytics_workspace_id, azurerm_log_analytics_workspace.workspace.id)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_windows_function_app" "function" {
  name                = "func-${var.app_base_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.additional_tags

  service_plan_id             = azurerm_service_plan.serverfarm.id
  storage_account_name        = azurerm_storage_account.storage.name
  storage_account_access_key  = azurerm_storage_account.storage.primary_access_key
  functions_extension_version = "~4"
  https_only                  = true

  app_settings = merge({
    "FUNCTIONS_INPROC_NET8_ENABLED" = "1"
    "WEBSITE_RUN_FROM_PACKAGE"      = "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/latest.zip"
    "WEBSITE_TIME_ZONE"             = var.time_zone
  }, local.acmebot_app_settings, local.auth_app_settings, var.additional_app_settings)

  dynamic "sticky_settings" {
    for_each = toset(length(local.auth_app_settings) != 0 ? [1] : [])

    content {
      app_setting_names = keys(local.auth_app_settings)
    }
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "auth_settings_v2" {
    for_each = toset(var.auth_settings != null ? [1] : [])

    content {
      auth_enabled           = var.auth_settings.enabled
      default_provider       = "azureactivedirectory"
      require_authentication = true
      unauthenticated_action = "RedirectToLoginPage"

      login {
        token_store_enabled = false
      }

      active_directory_v2 {
        client_id                  = var.auth_settings.active_directory.client_id
        client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
        tenant_auth_endpoint       = var.auth_settings.active_directory.tenant_auth_endpoint
      }
    }
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.insights.connection_string
    ftps_state                             = "Disabled"
    minimum_tls_version                    = "1.2"
    scm_minimum_tls_version                = "1.2"
    scm_use_main_ip_restriction            = true

    application_stack {
      dotnet_version = "v8.0"
    }

    ip_restriction_default_action = length(var.allowed_ip_addresses) != 0 ? "Deny" : "Allow"

    dynamic "ip_restriction" {
      for_each = var.allowed_ip_addresses

      content {
        ip_address = ip_restriction.value
      }
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
      sticky_settings["app_setting_names"]
    ]
  }
}

data "azurerm_function_app_host_keys" "function" {
  name                = azurerm_windows_function_app.function.name
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_windows_function_app.function
  ]
}

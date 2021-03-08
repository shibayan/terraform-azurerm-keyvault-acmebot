provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = "~> 2.0"
  }
}

resource "azurerm_storage_account" "storage" {
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = "Storage"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = false
  min_tls_version           = "TLS1_2"
}

resource "azurerm_app_service_plan" "serverfarm" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "functionapp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_application_insights" "insights" {
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
}

resource "azurerm_function_app" "function" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.serverfarm.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version                    = "~3"
  https_only                 = true
  client_affinity_enabled    = false
  enable_builtin_logging     = false
  min_tls_version            = "1.2"

  app_settings = merge({
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.insights.connection_string
    "FUNCTIONS_WORKER_RUNTIME"              = "dotnet"
    "WEBSITE_RUN_FROM_PACKAGE"              = "https://shibayan.blob.core.windows.net/azure-keyvault-letsencrypt/v3/latest.zip"
  }, local.acmebot_app_settings)

  identity {
    type = "SystemAssigned"
  }

  site_config {
    ftps_state = "Disabled"
  }
}
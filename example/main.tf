provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = "~> 3.0"
  }
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  upper   = false
  special = false
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "default" {
  name     = "rg-acmebot-module"
  location = "westus2"
}

resource "azurerm_key_vault" "default" {
  name                = "kv-acmebot-module-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  sku_name  = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "default" {
  key_vault_id = azurerm_key_vault.default.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = module.keyvault_acmebot.principal_id

  certificate_permissions = ["get", "list", "create", "update"]
}

module "keyvault_acmebot" {
  source  = "shibayan/keyvault-acmebot/azurerm"
  version = "~> 1.0"

  function_app_name     = "func-acmebot-module-${random_string.random.result}"
  app_service_plan_name = "plan-acmebot-module-${random_string.random.result}"
  storage_account_name  = "stacmebotmodule${random_string.random.result}"
  app_insights_name     = "appi-acmebot-module-${random_string.random.result}"
  workspace_name        = "log-acmebot-module-${random_string.random.result}"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  mail_address          = "YOUR-EMAIL-ADDRESS"
  vault_uri             = azurerm_key_vault.default.vault_uri

  azure_dns = {
    subscription_id = data.azurerm_client_config.current.subscription_id
  }
}

output "principal_id" {
  value = module.keyvault_acmebot.principal_id
}
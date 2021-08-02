provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = "~> 2.0"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "default" {
  name     = "rg-acmebot-module"
  location = "westus2"
}

resource "azurerm_key_vault" "default" {
  name                = "kv-acmebot-module"
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

  function_app_name     = "func-acmebot-module"
  app_service_plan_name = "plan-acmebot-module"
  storage_account_name  = "stacmebotmodule"
  app_insights_name     = "appi-acmebot-module"
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
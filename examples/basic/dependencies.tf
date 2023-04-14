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

  certificate_permissions = ["Get", "List", "Create", "Update"]
}
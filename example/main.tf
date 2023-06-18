provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = "~> 3.0"
    azuread = "~> 2.0"
  }
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  upper   = false
  special = false
}

resource "time_rotating" "default" {
  rotation_days = 180
}

data "azuread_client_config" "current" {}

resource "azuread_application" "default" {
  display_name = "Acmebot ${random_string.random.result}"

  web {
    redirect_uris = ["https://func-acmebot-module-${random_string.random.result}.azurewebsites.net/.auth/login/aad/callback"]

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_application_password" "default" {
  application_object_id = azuread_application.default.object_id
  end_date_relative     = "8640h"

  rotate_when_changed = {
    rotation = time_rotating.default.id
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "default" {
  name     = "rg-acmebot"
  location = "westus2"
}

resource "azurerm_key_vault" "default" {
  name                = "kv-acmebot-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  sku_name = "standard"

  enable_rbac_authorization = true
  tenant_id                 = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_assignment" "default" {
  scope                = azurerm_key_vault.default.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = module.keyvault_acmebot.principal_id
}

module "keyvault_acmebot" {
  source  = "shibayan/keyvault-acmebot/azurerm"
  version = "~> 2.0"

  app_base_name       = "acmebot-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  mail_address        = "YOUR-EMAIL-ADDRESS"
  vault_uri           = azurerm_key_vault.default.vault_uri

  azure_dns = {
    subscription_id = data.azurerm_client_config.current.subscription_id
  }

  auth_settings = {
    enabled = true
    active_directory = {
      client_id            = azuread_application.default.application_id
      client_secret        = azuread_application_password.default.value
      tenant_auth_endpoint = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
    }
  }

  allowed_ip_addresses = ["192.168.10.1/32"]
}

output "principal_id" {
  value = module.keyvault_acmebot.principal_id
}
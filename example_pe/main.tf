locals {
  suffix_clean = replace(var.suffix, "-", "")
}

data azurerm_key_vault "default" {
    name                = "${var.keyvault_name}"
    resource_group_name = "${var.keyvault_rg_name}"
}

data "azurerm_client_config" "current" {
}

data "azurerm_dns_zone" "default" {
  name                = "${var.dns_zone_name}"
  resource_group_name = "${var.dns_zone_rg}"
}

data "azurerm_resource_group" "default" {
    name     = "${var.suffix}-rg"
}

resource "azurerm_subnet" "vnet_int" {
  resource_group_name  = "${var.vnet_int_rg}"
  virtual_network_name = "${var.vnet_int_name}"
  name                 = "${var.vnet_int_subnet_name}"
  address_prefixes     =    var.vnet_int_subnet_address_prefixes
  private_link_service_network_policies_enabled = true

  delegation {
    name = "serverFarms"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints    = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Web"
  ]
}

resource "azurerm_subnet" "vnet_pe" {
  resource_group_name  = "${var.vnet_pe_rg}"
  virtual_network_name = "${var.vnet_pe_name}"
  name                 = "${var.vnet_pe_subnet_name}"
  address_prefixes     =    var.vnet_pe_subnet_address_prefixes
  service_endpoints    = [
    "Microsoft.Storage",
    "Microsoft.Web"
  ]
  private_endpoint_network_policies_enabled = false
  private_link_service_network_policies_enabled = false
}

module "keyvault_acmebot" {
  # source  = "shibayan/keyvault-acmebot/azurerm"
  # version = "2.0.3"

  source = "github.com/shibayan/terraform-azurerm-keyvault-acmebot"
  # https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/releases

  function_app_name     = "${var.suffix}-func"
  app_service_plan_name = "${var.suffix}-plan"
  app_insights_name     = "${var.suffix}-appi"
  workspace_name        = "${var.suffix}-log"
  mail_address          = "${var.email}"
  allowed_ip_addresses  =    var.allowed_ip_addresses
  storage_account_name  = "${local.suffix_clean}st"
  resource_group_name   = data.azurerm_resource_group.default.name
  location              = data.azurerm_resource_group.default.location
  vault_uri             = data.azurerm_key_vault.default.vault_uri

  sku_name                               = var.sku_name
  app_scale_limit                        = var.app_scale_limit
  vnet_route_all_enabled                 = var.vnet_route_all_enabled
  virtual_network_subnet_ids_integration = [azurerm_subnet.vnet_int.id]
  virtual_network_subnet_ids_pe          = [azurerm_subnet.vnet_pe.id ]
  private_dns_zone_rg                    = var.private_dns_rg
  private_dns_zone_names_function        = var.private_dns_zone_names_function
  private_dns_zone_names_storage         = var.private_dns_zone_names_storage

  auth_settings         = {
    enabled             = true
    issuer              = null
    token_store_enabled = true
    unauthenticated_client_action = "RedirectToLoginPage"
    active_directory    = {
      client_id         = "${var.app_active_directory_client_id}"
      allowed_audiences = null
    }
  }
  time_zone            = "CET"
  webhook_url          = "${var.webhook_url}"
  mitigate_chain_order = true

  azure_dns = {
    subscription_id = data.azurerm_client_config.current.subscription_id
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/${var.app_version}.zip"
  }

  tags = merge(var.tags, {})

  depends_on = [
    azurerm_subnet.vnet_int,
    azurerm_subnet.vnet_pe
  ]
}

# https://github.com/shibayan/keyvault-acmebot/wiki/DNS-Provider-Configuration#azure-dns
resource "azurerm_role_assignment" "dns" {
  scope                = data.azurerm_dns_zone.default.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = module.keyvault_acmebot.principal_id

  depends_on = [
    module.keyvault_acmebot
  ]
}

resource "azurerm_key_vault_access_policy" "default" {
  key_vault_id = data.azurerm_key_vault.default.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = module.keyvault_acmebot.principal_id

  certificate_permissions = ["Get", "List", "Create", "Update"]

  depends_on = [
    module.keyvault_acmebot
  ]
}


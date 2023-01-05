resource "azurerm_storage_account" "storage" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = length(var.allowed_ip_addresses         ) > 0 ? null : var.allowed_ip_addresses
    virtual_network_subnet_ids = length(var.virtual_network_subnet_ids_pe) > 0 ? null : var.virtual_network_subnet_ids_pe
  }
}

resource "azurerm_service_plan" "serverfarm" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = "Windows"
  sku_name = var.sku_name
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "insights" {
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
}

resource "azurerm_windows_function_app" "function" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.serverfarm.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  functions_extension_version = "~4"
  https_only                  = true

  app_settings = merge({
    "WEBSITE_RUN_FROM_PACKAGE" = "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/latest.zip"
    "WEBSITE_TIME_ZONE"        = var.time_zone
  }, local.acmebot_app_settings, var.app_settings)

  identity {
    type = "SystemAssigned"
  }

  dynamic "auth_settings" {
    for_each = toset(var.auth_settings != null ? [1] : [])
    content {
      enabled                       = var.auth_settings.enabled
      unauthenticated_client_action = var.auth_settings.unauthenticated_client_action
      issuer                        = var.auth_settings.issuer
      token_store_enabled           = var.auth_settings.token_store_enabled
      active_directory {
        allowed_audiences = var.auth_settings.active_directory.allowed_audiences
        client_id         = var.auth_settings.active_directory.client_id
      }
    }
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.insights.connection_string
    ftps_state                             = "Disabled"
    minimum_tls_version                    = "1.2"
    always_on                              = false
    http2_enabled                          = true
    app_scale_limit                        = var.app_scale_limit
    vnet_route_all_enabled                 = var.vnet_route_all_enabled

    application_stack {
      dotnet_version = "6"
    }

    dynamic "ip_restriction" {
      for_each = var.allowed_ip_addresses
      content {
        ip_address = ip_restriction.value
      }
    }

    dynamic "ip_restriction" {
      for_each = local.virtual_network_subnet_ids_integration_dict
      content {
        virtual_network_subnet_id = ip_restriction.value
      }
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "swift_connection" {
  for_each = local.virtual_network_subnet_ids_integration_dict

  app_service_id = azurerm_windows_function_app.function.id
  subnet_id      = each.value
}

#resource "azurerm_public_ip" "pub" {
#  for_each = local.virtual_network_subnet_ids_pe_dict
#
#  name                = "${var.function_app_name}-public-ip"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#  sku                 = "Standard"
#  allocation_method   = "Static"
#}

#resource "azurerm_lb" "lb" {
#  for_each = local.virtual_network_subnet_ids_pe_dict
#
#  name                   = "${var.function_app_name}-lb"
#  sku                    = "Standard"
#  location               = var.location
#  resource_group_name    = var.resource_group_name
#
#  frontend_ip_configuration {
#    name                 = azurerm_public_ip.pub[each.key].name
#    public_ip_address_id = azurerm_public_ip.pub[each.key].id
#  }
#}

#resource "azurerm_private_link_service" "pls" {
#  for_each = local.virtual_network_subnet_ids_pe_dict
#
#  name                = "${var.function_app_name}-privatelink"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#
#  nat_ip_configuration {
#    name      = "${var.function_app_name}-privatelink-nat"
#    primary   = true
#    subnet_id = each.value
#  }
#
#  load_balancer_frontend_ip_configuration_ids = [
#    azurerm_lb.lb[each.key].frontend_ip_configuration.0.id,
#  ]
#}

resource "azurerm_private_endpoint" "func-pe" {
  for_each = local.virtual_network_subnet_ids_pe_dict

  name                = "${var.function_app_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value

  private_service_connection {
    name                           = "${var.function_app_name}-psc"
    #private_connection_resource_id = azurerm_private_link_service.pls[each.key].id
    private_connection_resource_id = azurerm_windows_function_app.function.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}

resource "azurerm_private_endpoint" "sto-pe" {
  for_each            = local.virtual_network_subnet_ids_pe_dict

  name                = "${var.storage_account_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value

  private_service_connection {
    name                           = "${var.storage_account_name}-psc"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

#resource "azurerm_private_dns_zone_virtual_network_link" "network_link_func" {
#  name                  = "${var.function_app_name}-netlink"
#  resource_group_name   = var.resource_group_name
#  private_dns_zone_name = local.private_dns_zone_func_name
#  virtual_network_id    = local.private_dns_zone_func_network_id
#}

#resource "azurerm_private_dns_zone_virtual_network_link" "network_link_sto" {
#  name                  = "${var.storage_account_name}-netlink"
#  resource_group_name   = var.resource_group_name
#  private_dns_zone_name = local.private_dns_zone_storage_name
#  virtual_network_id    = local.private_dns_zone_storage_network_id
#}

#locals {
#  private_dns_zone_func_name          = "privatelink.web.core.windows.net"
#  private_dns_zone_func_network_id    = "/subscriptions/22ddb27a-140e-4feb-8111-61bf1f76f06e/resourceGroups/BejoResearchFirewall/providers/Microsoft.Network/virtualNetworks/Research-vnet"
#
#  private_dns_zone_storage_name       = "privatelink.blob.core.windows.net"
#  private_dns_zone_storage_network_id = "/subscriptions/22ddb27a-140e-4feb-8111-61bf1f76f06e/resourceGroups/BejoResearchFirewall/providers/Microsoft.Network/virtualNetworks/Research-vnet"
#}

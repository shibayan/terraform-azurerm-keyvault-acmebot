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
  tags                            = merge(var.tags, {})

  network_rules {
    default_action             = "Deny"
    ip_rules                   = length(var.allowed_ip_addresses         ) > 0 ? var.allowed_ip_addresses          : null
    virtual_network_subnet_ids = concat(
      length(var.virtual_network_subnet_ids_pe         ) > 0 ? var.virtual_network_subnet_ids_pe          : [],
      length(var.virtual_network_subnet_ids_integration) > 0 ? var.virtual_network_subnet_ids_integration : []
    )
  }
}

resource "azurerm_service_plan" "serverfarm" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge(var.tags, {})

  os_type  = "Windows"
  sku_name = var.sku_name
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = merge(var.tags, {})
}

resource "azurerm_application_insights" "insights" {
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
  tags                = merge(var.tags, {})
  depends_on          = [
    azurerm_log_analytics_workspace.workspace
  ]
}

resource "azurerm_windows_function_app" "function" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.serverfarm.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  tags                       = merge(var.tags, {})

  functions_extension_version = "~4"
  https_only                  = true

  app_settings = merge({
    "WEBSITE_RUN_FROM_PACKAGE" = "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/latest.zip"
    "WEBSITE_TIME_ZONE"        = var.time_zone
  }, local.acmebot_app_settings, var.app_settings)

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = length(var.virtual_network_subnet_ids_integration) > 0 ? var.virtual_network_subnet_ids_integration[0] : null

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
      for_each = local.function_ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }

    #dynamic "scm_ip_restriction" {
    #  for_each = local.function_ip_restrictions
    #  content {
    #    ip_address                = ip_restriction.value.ip_address
    #    virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
    #  }
    #}
  }

  depends_on = [
    azurerm_storage_account.storage,
    azurerm_application_insights.insights,
    azurerm_service_plan.serverfarm
  ]
}

resource "azurerm_private_endpoint" "func-pe" {
  for_each = local.virtual_network_subnet_ids_pe_dict

  name                = "${var.function_app_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value
  tags                = merge(var.tags, {})

  private_service_connection {
    name                           = "${var.function_app_name}-psc"
    private_connection_resource_id = azurerm_windows_function_app.function.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  depends_on = [
    azurerm_windows_function_app.function
  ]
}

resource "azurerm_private_endpoint" "sto-pe" {
  for_each            = merge(
    [
      for k, subnet_id in local.virtual_network_subnet_ids_pe_dict: {
        for subresource_name in ["blob", "queue", "table"]: {
          "${k}-${subresource_name}" => {
            "subnet_id" = subnet_id,
            "subresource_name" = subresource_name
          }
        }
      }
    ]
  )

  name                = "${var.storage_account_name}-${each.value.subresource_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id
  tags                = merge(var.tags, {})

  private_service_connection {
    name                           = "${var.storage_account_name}-psc"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = [each.value.subresource_name]
  }

  depends_on = [
    azurerm_storage_account.storage
  ]
}

# resource "azurerm_private_endpoint" "sto-blob-pe" {
#   for_each            = local.virtual_network_subnet_ids_pe_dict

#   name                = "${var.storage_account_name}-blob-pe"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = each.value
#   tags                = merge(var.tags, {})

#   private_service_connection {
#     name                           = "${var.storage_account_name}-psc"
#     private_connection_resource_id = azurerm_storage_account.storage.id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]
#   }

#   depends_on = [
#     azurerm_storage_account.storage
#   ]
# }

# resource "azurerm_private_endpoint" "sto-queue-pe" {
#   for_each            = local.virtual_network_subnet_ids_pe_dict

#   name                = "${var.storage_account_name}-queue-pe"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = each.value
#   tags                = merge(var.tags, {})

#   private_service_connection {
#     name                           = "${var.storage_account_name}-psc"
#     private_connection_resource_id = azurerm_storage_account.storage.id
#     is_manual_connection           = false
#     subresource_names              = ["queue"]
#   }

#   depends_on = [
#     azurerm_storage_account.storage
#   ]
# }

# resource "azurerm_private_endpoint" "sto-table-pe" {
#   for_each            = local.virtual_network_subnet_ids_pe_dict

#   name                = "${var.storage_account_name}-queue-pe"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = each.value
#   tags                = merge(var.tags, {})

#   private_service_connection {
#     name                           = "${var.storage_account_name}-psc"
#     private_connection_resource_id = azurerm_storage_account.storage.id
#     is_manual_connection           = false
#     subresource_names              = ["table"]
#   }

#   depends_on = [
#     azurerm_storage_account.storage
#   ]
# }

resource "azurerm_private_dns_a_record" "dns_a_storage_blob" {
  for_each            = local.virtual_network_subnet_ids_pe_dict

  zone_name           = var.private_dns_zone_storage_blob_name
  resource_group_name = var.private_dns_zone_rg
  ttl                 = 300
  name                = var.storage_account_name
  records             = azurerm_private_endpoint.sto-blob-pe[each.key].custom_dns_configs[0].ip_addresses
  tags                = merge(var.tags, {})

  depends_on = [
    azurerm_private_endpoint.sto-blob-pe
  ]
}

resource "azurerm_private_dns_a_record" "dns_a_storage_queue" {
  for_each            = local.virtual_network_subnet_ids_pe_dict

  zone_name           = var.private_dns_zone_storage_queue_name
  resource_group_name = var.private_dns_zone_rg
  ttl                 = 300
  name                = var.storage_account_name
  records             = azurerm_private_endpoint.sto-queue-pe[each.key].custom_dns_configs[0].ip_addresses
  tags                = merge(var.tags, {})

  depends_on = [
    azurerm_private_endpoint.sto-queue-pe
  ]
}

resource "azurerm_private_dns_a_record" "dns_a_function_web" {
  for_each            = merge(
    flatten([
      for k, v in local.virtual_network_subnet_ids_pe_dict: [
        for l in [0, 1]: {
          "${k}-${l}" = {
            key    = k
            conf   = l
          }
        }
      ]
    ])
  ...)

  zone_name           = var.private_dns_zone_function_web_name
  resource_group_name = var.private_dns_zone_rg
  ttl                 = 300
  name                = replace(azurerm_private_endpoint.func-pe[each.value.key].custom_dns_configs[each.value.conf].fqdn, ".azurewebsites.net", "")
  records             =         azurerm_private_endpoint.func-pe[each.value.key].custom_dns_configs[each.value.conf].ip_addresses
  tags                = merge(var.tags, {})

  depends_on = [
    azurerm_private_endpoint.func-pe
  ]
}

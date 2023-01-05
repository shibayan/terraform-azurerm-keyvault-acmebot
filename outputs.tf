output "principal_id" {
  value       = azurerm_windows_function_app.function.identity[0].principal_id
  description = "Created Managed Identity Principal ID"
}

output "tenant_id" {
  value       = azurerm_windows_function_app.function.identity[0].tenant_id
  description = "Created Managed Identity Tenant ID"
}

output "allowed_ip_addresses" {
  value       = var.allowed_ip_addresses
  description = "IP addresses that are allowed to access the Acmebot UI."
}

output "" {
  value       = azurerm_subnet.vnet_int.name
  description = "VNET integration name"
}

output "" {
  value       = azurerm_subnet.vnet_pe.name
  description = "VNET Private endpoing name"
}

output "" {
  value       = azurerm_private_endpoint.func-pe.id
  description = "Private Endpoint Function ID"
}

output "" {
  value       = azurerm_private_endpoint.func-pe.custom_dns_configs
  description = "Private Endpoint Function Custom DNS Configs"
}

output "" {
  value       = azurerm_private_endpoint.sto-pe.id
  description = "Private Endpoint Storage ID"
}

output "" {
  value       = azurerm_private_endpoint.sto-pe.custom_dns_configs
  description = "Private Endpoint Storage Custom DNS Configs"
}

output "" {
  value       = azurerm_storage_account.storage.id
  description = "Storage ID"
}

output "" {
  value       = azurerm_windows_function_app.function.id
  description = "Function ID"
}

output "" {
  value       = azurerm_windows_function_app.function.default_hostname
  description = "Function Default Hostname"
}
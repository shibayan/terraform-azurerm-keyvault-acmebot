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

azurerm_subnet.vnet_int.name
azurerm_subnet.vnet_pe.name
azurerm_private_endpoint.func-pe.id
azurerm_private_endpoint.func-pe.custom_dns_configs
azurerm_private_endpoint.sto-pe.id
azurerm_private_endpoint.sto-pe.custom_dns_configs
azurerm_storage_account.storage.id
azurerm_windows_function_app.function.id
azurerm_windows_function_app.function.default_hostname

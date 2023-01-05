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

output "private_endpoint_function_id" {
  value       = azurerm_private_endpoint.func-pe.id
  description = "Private Endpoint Function Id"
}

output "private_endpoint_function_dns_configs" {
  value       = azurerm_private_endpoint.func-pe.custom_dns_configs
  description = "Private Endpoint Function Custom DNS Configs"
}

output "private_endpoint_storage_id" {
  value       = azurerm_private_endpoint.sto-pe.id
  description = "Private Endpoint Storage ID"
}

output "private_endpoint_storage_dns_configs" {
  value       = azurerm_private_endpoint.sto-pe.custom_dns_configs
  description = "Private Endpoint Storage Custom DNS Configs"
}

output "storage_id" {
  value       = azurerm_storage_account.storage.id
  description = "Storage ID"
}

output "function_id" {
  value       = azurerm_windows_function_app.function.id
  description = "Function ID"
}

output "function_default_hostname" {
  value       = azurerm_windows_function_app.function.default_hostname
  description = "Function Default Hostname"
}
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

output "outbound_ip_address_list" {
  value       = azurerm_windows_function_app.function.outbound_ip_address_list
  description = "A list of outbound IP addresses."
}

output "possible_outbound_ip_address_list" {
  value       = azurerm_windows_function_app.function.possible_outbound_ip_address_list
  description = "A list of possible outbound IP addresses, not all of which are necessarily in use. This is a superset of outbound_ip_address_list."
}

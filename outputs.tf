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

output "api_key" {
  value       = data.azurerm_function_app_host_keys.function.default_function_key
  description = "Created Default Functions API Key"
  sensitive   = true
}

output "log_analytics_workspace_id" {
  value       = try(azurerm_log_analytics_workspace.workspace[0].id, var.log_analytics_workspace_id)
  description = "The ID for the log analytics workspace used in the module."
}

output "application_insights_id" {
  value       = azurerm_application_insights.insights.id
  description = "The resource ID for the application insights resource setup by this module."
}

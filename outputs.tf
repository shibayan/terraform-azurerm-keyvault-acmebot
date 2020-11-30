output "principal_id" {
  value       = azurerm_function_app.function.identity[0].principal_id
  description = "Created Managed Identity Principal ID"
}

output "tenant_id" {
  value       = azurerm_function_app.function.identity[0].tenant_id
  description = "Created Managed Identity Tenant ID"
}
output "principal_id" {
  value       = azurerm_function_app.function.identity.principal_id
  description = "Created Managed Identity Principal ID"
}

output "tenant_id" {
  value       = azurerm_function_app.function.identity.tenant_id
  description = "Created Managed Identity Tenant ID"
}
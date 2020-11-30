output "principal_id" {
  value = azurerm_function_app.function.identity.principal_id
}

output "tenant_id" {
  value = azurerm_function_app.function.identity.tenant_id
}
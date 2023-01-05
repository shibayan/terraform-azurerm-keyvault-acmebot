output "principal_id" {
  value       = azurerm_windows_function_app.function.identity[0].principal_id
  description = "Created Managed Identity Principal ID"
}

output "tenant_id" {
  value       = azurerm_windows_function_app.function.identity[0].tenant_id
  description = "Created Managed Identity Tenant ID"
}



output "function_app_name" {
  value       = var.function_app_name
  description = "function_app_name"
}

output "app_service_plan_name" {
  value       = var.app_service_plan_name
  description = "app_service_plan_name"
}

output "app_insights_name" {
  value       = var.app_insights_name
  description = "app_insights_name"
}

output "workspace_name" {
  value       = var.workspace_name
  description = "workspace_name"
}

output "storage_account_name" {
  value       = var.storage_account_name
  description = "storage_account_name"
}



output "storage_id" {
  value       = azurerm_storage_account.storage.id
  description = "Storage ID"
}

output "storage_name" {
  value       = azurerm_storage_account.storage.name
  description = "Storage name"
}

output "storage_private_endpoint_id" {
  value       = {
    for k, pe in azurerm_private_endpoint.sto-pe : k => pe.id
  }
  description = "Private Endpoint Storage ID"
}

output "storage_private_endpoint_dns_configs" {
  value       = {
    for k, pe in azurerm_private_endpoint.sto-pe : k => { fqdn = pe.custom_dns_configs.fqdn, ip_addresses = pe.custom_dns_configs.ip_addresses }
  }
  description = "Private Endpoint Storage Custom DNS Configs"
}



output "function_id" {
  value       = azurerm_windows_function_app.function.id
  description = "Function ID"
}

output "function_name" {
  value       = azurerm_windows_function_app.function.name
  description = "Function name"
}

output "function_allowed_ip_addresses" {
  value       = var.allowed_ip_addresses
  description = "IP addresses that are allowed to access the Acmebot UI."
}

output "function_private_endpoint_id" {
  value       = {
    for k, pe in azurerm_private_endpoint.func-pe : k => pe.id
  }
  description = "Private Endpoint Function Id"
}

output "function_private_endpoint_dns_configs" {
  value       = {
    for k, pe in azurerm_private_endpoint.func-pe : k => { fqdn = pe.custom_dns_configs.fqdn, ip_addresses = pe.custom_dns_configs.ip_addresses }
  }
  description = "Private Endpoint Function Custom DNS Configs"
}

output "function_default_hostname" {
  value       = azurerm_windows_function_app.function.default_hostname
  description = "Function Default Hostname"
}

output "function_ip_restrictions" {
  value       = local.function_ip_restrictions
  description = "IP restriction for Function"
}

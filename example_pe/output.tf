output "acme" {
  value = module.keyvault_acmebot
}

output "vnet_int_id" {
    value = azurerm_subnet.vnet_int.id
}

output "vnet_pe_id" {
    value = azurerm_subnet.vnet_pe.id
}

output "dns_rule_assignment" {
    value = azurerm_role_assignment.dns.id
}

output "key_vault_access_policy_id" {
    value = azurerm_key_vault_access_policy.default.id
}

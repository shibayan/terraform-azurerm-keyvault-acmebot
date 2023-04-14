module "keyvault_acmebot" {
  source  = "shibayan/keyvault-acmebot/azurerm"
  version = "~> 2.0"

  function_app_name     = "func-acmebot-module-${random_string.random.result}"
  app_service_plan_name = "plan-acmebot-module-${random_string.random.result}"
  storage_account_name  = "stacmebotmodule${random_string.random.result}"
  app_insights_name     = "appi-acmebot-module-${random_string.random.result}"
  workspace_name        = "log-acmebot-module-${random_string.random.result}"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  email_address         = "YOUR-EMAIL-ADDRESS"
  vault_uri             = azurerm_key_vault.default.vault_uri
  tags = {
    my_tag = "some value"
  }

  azure_dns = {
    subscription_id = data.azurerm_client_config.current.subscription_id
  }

  allowed_ip_addresses = ["0.0.0.1"]
}

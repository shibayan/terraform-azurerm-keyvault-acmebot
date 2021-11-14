# Key Vault Acmebot Terraform module

[![Validate](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/actions/workflows/validate.yml/badge.svg)](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/actions/workflows/validate.yml)
[![Release](https://img.shields.io/github/release/shibayan/terraform-azurerm-keyvault-acmebot.svg)](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/releases/latest)
[![License](https://img.shields.io/github/license/shibayan/terraform-azurerm-keyvault-acmebot.svg)](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/blob/master/LICENSE)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-5c4ee5.svg)](https://registry.terraform.io/modules/shibayan/keyvault-acmebot/azurerm/latest)

## Usage

```hcl
module "keyvault_acmebot" {
  source  = "shibayan/keyvault-acmebot/azurerm"
  version = "~> 1.0"

  function_app_name     = "func-acmebot-module"
  app_service_plan_name = "plan-acmebot-module"
  storage_account_name  = "stacmebotmodule"
  app_insights_name     = "appi-acmebot-module"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  mail_address          = "YOUR-EMAIL-ADDRESS"
  vault_uri             = azurerm_key_vault.default.vault_uri

  azure_dns = {
    subscription_id = data.azurerm_client_config.current.subscription_id
  }
}
```

## License

This project is licensed under the [Apache License 2.0](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/blob/master/LICENSE)

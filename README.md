<!-- BEGIN_TF_DOCS -->
# Key Vault Acmebot Terraform module

[![Validate](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/actions/workflows/validate.yml/badge.svg)](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/actions/workflows/validate.yml)
[![Release](https://badgen.net/github/release/shibayan/terraform-azurerm-keyvault-acmebot)](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/releases/latest)
[![License](https://badgen.net/github/license/shibayan/terraform-azurerm-keyvault-acmebot)](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/blob/master/LICENSE)
[![Terraform Registry](https://badgen.net/badge/terraform/registry/5c4ee5)](https://registry.terraform.io/modules/shibayan/keyvault-acmebot/azurerm/latest)

## License

This project is licensed under the [Apache License 2.0](https://github.com/shibayan/terraform-azurerm-keyvault-acmebot/blob/master/LICENSE)

## Examples

```hcl
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
```

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acme_endpoint | Certification authority ACME Endpoint. | `string` | `"https://acme-v02.api.letsencrypt.org/"` | no |
| additional_tags | A map of additional tags to assign to each of the resources created by the module. | `map(string)` | `{}` | no |
| allowed_ip_addresses | A list of allowed ip addresses that can access the Acmebot UI. | `list(string)` | `[]` | no |
| app_insights_name | The name of the Application Insights to create. | `string` | n/a | yes |
| app_service_plan_name | The name of the App Service Plan to create. | `string` | n/a | yes |
| app_settings | Additional settings to set for the function app | `map(string)` | `{}` | no |
| auth_settings | Authentication settings for the function app | ```object({ enabled = bool issuer = string token_store_enabled = bool unauthenticated_client_action = string active_directory = object({ client_id = string allowed_audiences = list(string) }) })``` | `null` | no |
| azure_dns | n/a | ```object({ subscription_id = string })``` | `null` | no |
| cloudflare | n/a | ```object({ api_token = string })``` | `null` | no |
| custom_dns | n/a | ```object({ endpoint = string api_key = string api_key_header_name = string propagation_seconds = number })``` | `null` | no |
| dns_made_easy | n/a | ```object({ api_key = string secret_key = string })``` | `null` | no |
| email_address | Email address for ACME account. | `string` | n/a | yes |
| environment | The name of the Azure environment. | `string` | `"AzureCloud"` | no |
| external_account_binding | n/a | ```object({ key_id = string hmac_key = string algorithm = string })``` | `null` | no |
| function_app_name | The name of the Function App to create. | `string` | n/a | yes |
| gandi | n/a | ```object({ api_key = string })``` | `null` | no |
| go_daddy | n/a | ```object({ api_key = string api_secret = string })``` | `null` | no |
| google_dns | n/a | ```object({ key_file64 = string })``` | `null` | no |
| keyvault_acmebot_version | The version of Key Vault ACMEBot to dpeloy. | `string` | `"latest"` | no |
| location | Azure region to create resources. | `string` | n/a | yes |
| mitigate_chain_order | Mitigate certificate ordering issues that occur with some services. | `bool` | `false` | no |
| resource_group_name | Resource group name to be added. | `string` | n/a | yes |
| route_53 | n/a | ```object({ access_key = string secret_key = string region = string })``` | `null` | no |
| storage_account_name | The name of the Storage Account to create. | `string` | n/a | yes |
| time_zone | The name of time zone as the basis for automatic update timing. | `string` | `"UTC"` | no |
| trans_ip | n/a | ```object({ customer_name = string private_key_name = string })``` | `null` | no |
| vault_uri | URL of the Key Vault to store the issued certificate. | `string` | n/a | yes |
| webhook_url | The webhook where notifications will be sent. | `string` | `null` | no |
| workspace_name | The name of the Log Analytics Workspace to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| allowed_ip_addresses | IP addresses that are allowed to access the Acmebot UI. |
| principal_id | Created Managed Identity Principal ID |
| tenant_id | Created Managed Identity Tenant ID |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_log_analytics_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_service_plan.serverfarm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_windows_function_app.function](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |
<!-- END_TF_DOCS -->
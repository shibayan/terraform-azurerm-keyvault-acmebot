locals {

  internal_tags = {
    KeyvaultACMEBotVersion    = var.keyvault_acmebot_version
    TerraformModuleRepository = "https://github.com/shibayan/terraform-azurerm-keyvault-acmebot"
    TerraformModuleVersion    = "2.2.0" # Should include a github action to ensure
                                        # that this tag is pushed when this merges
                                        # or that the PR generates an error
  }

  all_tags = merge(
    var.additional_tags, # lowest priority on merge
    local.internal_tags  # highest priority on merge
  )

  ###
  # ACMEBot function variables
  ###
  external_account_binding = var.external_account_binding != null ? {
    "Acmebot:ExternalAccountBinding:KeyId"     = var.external_account_binding.key_id
    "Acmebot:ExternalAccountBinding:HmacKey"   = var.external_account_binding.hmac_key
    "Acmebot:ExternalAccountBinding:Algorithm" = var.external_account_binding.algorithm
  } : {}

  azure_dns = var.azure_dns != null ? {
    "Acmebot:AzureDns:SubscriptionId" = var.azure_dns.subscription_id
  } : {}

  cloudflare = var.cloudflare != null ? {
    "Acmebot:Cloudflare:ApiToken" = var.cloudflare.api_token
  } : {}

  custom_dns = var.custom_dns != null ? {
    "Acmebot:CustomDns:Endpoint"           = var.custom_dns.endpoint
    "Acmebot:CustomDns:ApiKey"             = var.custom_dns.api_key
    "Acmebot:CustomDns:ApiKeyHeaderName"   = var.custom_dns.api_key_header_name
    "Acmebot:CustomDns:PropagationSeconds" = var.custom_dns.propagation_seconds
  } : {}

  dns_made_easy = var.dns_made_easy != null ? {
    "Acmebot:DnsMadeEasy:ApiKey"    = var.dns_made_easy.api_key
    "Acmebot:DnsMadeEasy:SecretKey" = var.dns_made_easy.secret_key
  } : {}

  gandi = var.gandi != null ? {
    "Acmebot:Gandi:ApiKey" = var.gandi.api_key
  } : {}

  go_daddy = var.go_daddy != null ? {
    "Acmebot:GoDaddy:ApiKey"    = var.go_daddy.api_key
    "Acmebot:GoDaddy:ApiSecret" = var.go_daddy.api_secret
  } : {}

  google_dns = var.google_dns != null ? {
    "Acmebot:GoogleDns:KeyFile64" = var.google_dns.key_file64
  } : {}

  route_53 = var.route_53 != null ? {
    "Acmebot:Route53:AccessKey" = var.route_53.access_key
    "Acmebot:Route53:SecretKey" = var.route_53.secret_key
    "Acmebot:Route53:Region"    = var.route_53.region
  } : {}

  trans_ip = var.trans_ip != null ? {
    "Acmebot:TransIp:CustomerName"   = var.trans_ip.customer_name
    "Acmebot:TransIp:PrivateKeyName" = var.trans_ip.private_key_name
  } : {}

  webhook_url = var.webhook_url != null ? {
    "Acmebot:Webhook" = var.webhook_url
  } : {}

  common = {
    "Acmebot:Contacts"           = var.email_address
    "Acmebot:Endpoint"           = var.acme_endpoint
    "Acmebot:VaultBaseUrl"       = var.vault_uri
    "Acmebot:Environment"        = var.environment
    "Acmebot:MitigateChainOrder" = var.mitigate_chain_order
  }

  acmebot_app_settings = merge(
    local.common,
    local.external_account_binding,
    local.azure_dns,
    local.cloudflare,
    local.custom_dns,
    local.dns_made_easy,
    local.gandi,
    local.go_daddy,
    local.google_dns,
    local.route_53,
    local.trans_ip,
    local.webhook_url,
  )

}

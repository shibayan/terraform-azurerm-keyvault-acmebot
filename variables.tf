variable "function_app_name" {
  type        = string
  description = "The name of the Function App to create."
}

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "A list of allowed ip addresses that can access the Acmebot UI."
  default     = []
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the App Service Plan to create."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account to create."
}

variable "app_insights_name" {
  type        = string
  description = "The name of the Application Insights to create."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name to be added."
}

variable "location" {
  type        = string
  description = "Azure region to create resources."
}

variable "vault_uri" {
  type        = string
  description = "URL of the Key Vault to store the issued certificate."
}

variable "mail_address" {
  type        = string
  description = "Email address for ACME account."
}

variable "acme_endpoint" {
  type        = string
  description = "Certification authority ACME Endpoint."
  default     = "https://acme-v02.api.letsencrypt.org/"
}

variable "environment" {
  type        = string
  description = "The name of the Azure environment."
  default     = "AzureCloud"
}

variable "webhook_url" {
  type        = string
  description = "The webhook where notifications will be sent."
  default     = ""
}

variable "external_account_binding" {
  type = object({
    key_id    = string
    hmac_key  = string
    algorithm = string
  })
  default = null
}

variable "azure_dns" {
  type = object({
    subscription_id = string
  })
  default = null
}

variable "cloudflare" {
  type = object({
    api_token = string
  })
  default = null
}

variable "custom_dns" {
  type = object({
    endpoint            = string
    api_key             = string
    api_key_header_name = string
    propagation_seconds = number
  })
  default = null
}

variable "dns_made_easy" {
  type = object({
    api_key    = string
    secret_key = string
  })
  default = null
}

variable "go_daddy" {
  type = object({
    api_key    = string
    api_secret = string
  })
  default = null
}

variable "google_dns" {
  type = object({
    key_file64 = string
  })
  default = null
}

variable "gratis_dns" {
  type = object({
    username = string
    password = string
  })
  default = null
}

variable "trans_ip" {
  type = object({
    customer_name    = string
    private_key_name = string
  })
  default = null
}

locals {
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

  go_daddy = var.go_daddy != null ? {
    "Acmebot:GoDaddy:ApiKey"    = var.go_daddy.api_key
    "Acmebot:GoDaddy:ApiSecret" = var.go_daddy.api_secret
  } : {}

  google_dns = var.google_dns != null ? {
    "Acmebot:GoogleDns:KeyFile64" = var.google_dns.key_file64
  } : {}

  gratis_dns = var.gratis_dns != null ? {
    "Acmebot:GratisDns:Username" = var.gratis_dns.username
    "Acmebot:GratisDns:Password" = var.gratis_dns.password
  } : {}

  trans_ip = var.trans_ip != null ? {
    "Acmebot:TransIp:CustomerName"   = var.trans_ip.customer_name
    "Acmebot:TransIp:PrivateKeyName" = var.trans_ip.private_key_name
  } : {}

  webhook_url = var.webhook_url != null ? {
    "Acmebot:Webhook" = var.webhook_url
  } : {}

  common = {
    "Acmebot:Contacts"     = var.mail_address
    "Acmebot:Endpoint"     = var.acme_endpoint
    "Acmebot:VaultBaseUrl" = var.vault_uri
    "Acmebot:Environment"  = var.environment
  }

  acmebot_app_settings = merge(
    local.common,
    local.external_account_binding,
    local.azure_dns,
    local.cloudflare,
    local.custom_dns,
    local.dns_made_easy,
    local.go_daddy,
    local.google_dns,
    local.gratis_dns,
    local.trans_ip,
    local.webhook_url,
  )
}

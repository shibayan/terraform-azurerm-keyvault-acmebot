variable "function_app_name" {
  type        = string
  description = "The name of the Function App to create."
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

variable "google" {
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
  azure_dns = var.azure_dns != null ? {
    "Acmebot:AzureDns:SubscriptionId" = var.azure_dns.subscription_id
  } : {}

  cloudflare = var.cloudflare != null ? {
    "Acmebot:Cloudflare:ApiToken" = var.cloudflare.api_token
  } : {}

  google = var.google != null ? {
    "Acmebot:Google:KeyFile64" = var.google.key_file64
  } : {}

  gratis_dns = var.gratis_dns != null ? {
    "Acmebot:GratisDns:Username" = var.gratis_dns.username
    "Acmebot:GratisDns:Password" = var.gratis_dns.password
  } : {}

  trans_ip = var.trans_ip != null ? {
    "Acmebot:TransIp:CustomerName"   = var.trans_ip.customer_name
    "Acmebot:TransIp:PrivateKeyName" = var.trans_ip.private_key_name
  } : {}

  acmebot_app_settings = merge({
    "Acmebot:Contacts"     = var.mail_address
    "Acmebot:Endpoint"     = var.acme_endpoint
    "Acmebot:VaultBaseUrl" = var.vault_uri
    "Acmebot:Environment"  = var.environment
  }, local.azure_dns, local.cloudflare, local.google, local.gratis_dns, local.trans_ip)
}
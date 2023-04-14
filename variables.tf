variable "acme_endpoint" {
  type        = string
  description = "Certification authority ACME Endpoint."
  default     = "https://acme-v02.api.letsencrypt.org/"
}

variable "additional_tags" {
  type        = map(string)
  description = "A map of additional tags to assign to each of the resources created by the module."
  default     = {}
}

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "A list of allowed ip addresses that can access the Acmebot UI."
  default     = []
}

variable "app_insights_name" {
  type        = string
  description = "The name of the Application Insights to create."
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the App Service Plan to create."
}

variable "app_settings" {
  description = "Additional settings to set for the function app"
  type        = map(string)
  default     = {}
}

variable "auth_settings" {
  type = object({
    enabled                       = bool
    issuer                        = string
    token_store_enabled           = bool
    unauthenticated_client_action = string
    active_directory = object({
      client_id         = string
      allowed_audiences = list(string)
    })
  })
  description = "Authentication settings for the function app"
  default     = null
}

variable "environment" {
  type        = string
  description = "The name of the Azure environment."
  default     = "AzureCloud"
}

variable "email_address" { #rename
  type        = string
  description = "Email address for ACME account."

  # Check that a valid email address has been provided.
  validation {
    condition     = can(regex("^(.+)@(.+)\\.(.+)$", var.email_address))
    error_message = "A valid email address is required for `email_address`."
  }
}

variable "external_account_binding" {
  type = object({
    key_id    = string
    hmac_key  = string
    algorithm = string
  })
  default = null
}

variable "function_app_name" {
  type        = string
  description = "The name of the Function App to create."
}

variable "keyvault_acmebot_version" {
  type        = string
  description = "The version of Key Vault ACMEBot to dpeloy."
  default     = "latest"
}

variable "location" {
  type        = string
  description = "Azure region to create resources."
}

variable "mitigate_chain_order" {
  type        = bool
  description = "Mitigate certificate ordering issues that occur with some services."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name to be added."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account to create."
}

variable "time_zone" {
  type        = string
  description = "The name of time zone as the basis for automatic update timing."
  default     = "UTC"
}

variable "vault_uri" {
  type        = string
  description = "URL of the Key Vault to store the issued certificate."
}

variable "webhook_url" {
  type        = string
  description = "The webhook where notifications will be sent."
  default     = null
}

variable "workspace_name" {
  type        = string
  description = "The name of the Log Analytics Workspace to create."
}

###
# DNS Provider Configuration
###

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

variable "gandi" {
  type = object({
    api_key = string
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

variable "route_53" {
  type = object({
    access_key = string
    secret_key = string
    region     = string
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

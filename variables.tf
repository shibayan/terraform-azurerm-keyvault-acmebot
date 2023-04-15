variable "acme_endpoint" {
  description = "Certification authority ACME Endpoint."
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/"
}

variable "additional_tags" {
  description = "A map of additional tags to assign to each of the resources created by the module."
  type        = map(string)
  default     = {}
}

variable "allowed_ip_addresses" {
  description = "A list of allowed ip addresses that can access the Acmebot UI."
  type        = list(string)
  default     = []
}

variable "app_insights_name" {
  description = "The name of the Application Insights to create."
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the App Service Plan to create."
  type        = string
}

variable "app_settings" {
  description = "Additional settings to set for the function app"
  type        = map(string)
  default     = {}
}

variable "auth_settings" {
  description = "Authentication settings for the function app"
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
  default = null
}

variable "environment" {
  description = "The name of the Azure environment."
  type        = string
  default     = "AzureCloud"
}

variable "email_address" { #rename
  description = "Email address for ACME account."
  type        = string

  # Check that a valid email address has been provided.
  validation {
    condition     = can(regex("^(.+)@(.+)\\.(.+)$", var.email_address))
    error_message = "A valid email address is required for `email_address`."
  }
}

variable "external_account_binding" {
  description = ""
  type = object({
    key_id    = string
    hmac_key  = string
    algorithm = string
  })
  default = null
}

variable "function_app_name" {
  description = "The name of the Function App to create."
  type        = string
}

variable "keyvault_acmebot_version" {
  description = "The version of Key Vault ACMEBot to dpeloy."
  type        = string
  default     = "latest"

  # Make certain our versions is latest or 4+
  validation {
    condition = (contains("latest", var.keyvault_acmebot_version)
      || can(regex("4\\./d+\\./d+", var.keyvault_acmebot_version))
    )
    error_message = ""
  }
}

variable "location" {
  description = "Azure region to create resources."
  type        = string
}

variable "mitigate_chain_order" {
  description = "Mitigate certificate ordering issues that occur with some services."
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Resource group name to be added."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Storage Account to create."
  type        = string
}

variable "time_zone" {
  description = "The name of time zone as the basis for automatic update timing."
  type        = string
  default     = "UTC"
}

variable "vault_uri" {
  description = "URL of the Key Vault to store the issued certificate."
  type        = string
}

variable "webhook_url" {
  description = "The webhook where notifications will be sent."
  type        = string
  default     = null
}

variable "workspace_name" {
  description = "The name of the Log Analytics Workspace to create."
  type        = string
}

###
# DNS Provider Configuration
###

variable "azure_dns" {
  description = ""
  type = object({
    subscription_id = string
  })
  default = null
}

variable "cloudflare" {
  description = ""
  type = object({
    api_token = string
  })
  default = null
}

variable "custom_dns" {
  description = ""
  type = object({
    endpoint            = string
    api_key             = string
    api_key_header_name = string
    propagation_seconds = number
  })
  default = null
}

variable "dns_made_easy" {
  description = ""
  type = object({
    api_key    = string
    secret_key = string
  })
  default = null
}

variable "gandi" {
  description = ""
  type = object({
    api_key = string
  })
  default = null
}

variable "go_daddy" {
  description = ""
  type = object({
    api_key    = string
    api_secret = string
  })
  default = null
}

variable "google_dns" {
  description = ""
  type = object({
    key_file64 = string
  })
  default = null
}

variable "route_53" {
  description = ""
  type = object({
    access_key = string
    secret_key = string
    region     = string
  })
  default = null
}

variable "trans_ip" {
  description = ""
  type = object({
    customer_name    = string
    private_key_name = string
  })
  default = null
}

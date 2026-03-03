variable "app_base_name" {
  type        = string
  description = "The name of the App base to create."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name to be added."
}

variable "location" {
  type        = string
  description = "Azure region to create resources."
}

variable "auth_settings" {
  type = object({
    enabled = bool
    active_directory = object({
      client_id                  = string
      client_secret              = string
      client_secret_setting_name = optional(string, "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET")
      tenant_auth_endpoint       = string
    })
  })
  default     = null
  description = <<EOL
    Authentication settings for the function app.
    - enabled: Enable authentication for the function app.
    - active_directory: Active Directory authentication settings.
      - client_id: The client ID of the Azure AD application.
      - client_secret: The client secret of the Azure AD application. This can be set to the client ID of a user-assigned managed identity.
      - client_secret_setting_name: The name of the setting to store the client secret.
        Default is "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET". Set to "OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID" to use managed identity federated authentication instead of secret.
      - tenant_auth_endpoint: The authentication endpoint for the Azure AD tenant.
  EOL
}

variable "identity" {
  type = object({
    identity_ids = optional(list(string), [])
  })
  default     = {}
  description = "Object with the list of user assigned identity IDs to assign to the function app."
}

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "A list of allowed ip addresses that can access the Acmebot UI."
  default     = []
}

variable "additional_app_settings" {
  type        = map(string)
  description = "Additional settings to set for the function app"
  default     = {}
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to set for resources"
  default     = {}
}

variable "time_zone" {
  type        = string
  description = "The name of time zone as the basis for automatic update timing."
  default     = "UTC"
}

# Acmebot Configuration
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
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "environment" {
  type        = string
  description = "The name of the Azure environment."
  default     = "AzureCloud"
}

variable "webhook_url" {
  type        = string
  description = "The webhook where notifications will be sent."
  default     = null
}

variable "mitigate_chain_order" {
  type        = bool
  description = "Mitigate certificate ordering issues that occur with some services."
  default     = false
}

variable "app_role_required" {
  type        = bool
  description = "Specify whether additional App Role assignment is required during Azure AD authentication."
  default     = false
}

variable "external_account_binding" {
  type = object({
    key_id    = string
    hmac_key  = string
    algorithm = string
  })
  default = null
}

# DNS Provider Configuration
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

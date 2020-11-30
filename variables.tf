variable "function_app_name" {
  type = string
}

variable "app_service_plan_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "app_insights_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vault_uri" {
  type = string
}

variable "mail_address" {
  type = string
}

variable "acme_endpoint" {
  type    = string
  default = "https://acme-v02.api.letsencrypt.org/"
}

variable "environment" {
  type    = string
  default = "AzureCloud"
}
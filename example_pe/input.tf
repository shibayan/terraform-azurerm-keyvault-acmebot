variable "app_version" {
    type = string
    default = "4.0.4" #latest
    nullable = false
    # https://github.com/shibayan/keyvault-acmebot/releases
}


variable "webhook_url" {
    type      = string
    nullable  = false
    sensitive = true
}

variable "private_dns_rg" {
    type     = string
    nullable = false
}

variable "private_dns_zone_names_function" {
  type = object(
    {
      web = string
    }
  )
  description = "Private DNS zone name for function"
  default  = {
      web = "privatelink.azurewebsites.net"
  }
  nullable = true
}

variable "private_dns_zone_names_storage" {
  type = object(
    {
      blob  = string
      queue = string
      table = string
    }
  )
  description = "Private DNS zone names for storage"
  default   =   {
      blob  = "privatelink.blob.core.windows.net"
      queue = "privatelink.queue.core.windows.net"
      table = "privatelink.table.core.windows.net"
    }
  nullable = true
}

variable "vnet_int_rg" {
    type     = string
    nullable = false
}

variable "vnet_int_name" {
    type     = string
    nullable = false
}

variable "vnet_int_subnet_name" {
    type     = string
    nullable = false
}

variable "vnet_int_subnet_address_prefixes" {
    type     = list(string)
    nullable = false
}


variable "vnet_pe_rg" {
    type     = string
    nullable = false
}

variable "vnet_pe_name" {
    type     = string
    nullable = false
}

variable "vnet_pe_subnet_name" {
    type     = string
    default  = "AppsPe"
    nullable = false
}

variable "vnet_pe_subnet_address_prefixes" {
    type     = list(string)
    nullable = false
}


variable "sku_name" {
    type = string
    default = "P1v2"
    nullable = false
}

variable "app_scale_limit" {
    type     = number
    default  = 3
    nullable = false
}

variable "vnet_route_all_enabled" {
    type     = bool
    default  = true
    nullable = false
}


variable "domain_name" {
    type     = string
    nullable = false
}

variable "suffix" {
    type     = string
    nullable = false
}

variable "email" {
    type     = string
    nullable = false
}

variable "location" {
    type     = string
    default  = "westeurope"
    nullable = false
}

variable "keyvault_name" {
    type     = string
    nullable = false
}

variable "keyvault_rg_name" {
    type     = string
    nullable = false
}

variable "dns_zone_name" {
    type     = string
    nullable = false
}

variable "dns_zone_rg" {
    type     = string
    nullable = false
}

variable "allowed_ip_addresses" {
    type     = list(string)
    default  = []
    nullable = false
}

variable "app_active_directory_client_id" {
    type     = string
    nullable = false
}

variable "tags" {
  type = map
  nullable = true
  default = {}
}

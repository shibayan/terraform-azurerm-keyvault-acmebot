app_version = "4.0.4" #latest
# https://github.com/shibayan/keyvault-acmebot/releases

webhook_url = null

private_dns_rg                      = "dnsrg"
private_dns_zone_names_function     = {
    web   = "privatelink.azurewebsites.net"
}
private_dns_zone_names_storage      = {
    blob  = "privatelink.blob.core.windows.net"
    queue = "privatelink.queue.core.windows.net"
    table = "privatelink.table.core.windows.net"
}

vnet_int_rg                      = "dnsrg"
vnet_int_name                    = "vnet"
vnet_int_subnet_name             = "AppsFarms"
vnet_int_subnet_address_prefixes = ["10.0.0.0/26"]

vnet_pe_rg                       = "dnsrg"
vnet_pe_name                     = "vnet"
vnet_pe_subnet_name              = "AppsPe"
vnet_pe_subnet_address_prefixes  = ["10.0.0.64/26"]

sku_name                         = "P2v2"
app_scale_limit                  = 3
vnet_route_all_enabled           = true

domain_name                      = "acme.app"
suffix                           = "acme-app"
email                            = "user@acme.app"
location                         = "westeurope"
keyvault_name                    = "kv"
keyvault_rg_name                 = "dnsrg"
dns_zone_name                    = "acme.app"
dns_zone_rg                      = "dnsrg"
allowed_ip_addresses             = []
app_active_directory_client_id   = "00000000-0000-0000-0000-000000000000"

tags = {
    "deploy_date": "2023-01-06",
    "project_name": "let's encrypt dns",
    "source_url": "https://github.com/shibayan/keyvault-acmebot",
    "contact_person": "ACME User"
}

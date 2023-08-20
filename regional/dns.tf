data "azurerm_dns_zone" "subdomain" {
  count = 1

  name                = module.dev_envs.azure_environments[terraform.workspace]["test"]["dns-zone-name"]
  resource_group_name = data.azurerm_resource_group.dns.name
}

##
# Public Ingress
##
resource "azurerm_dns_a_record" "eks_public_ingress" {
  count = 1

  zone_name           = data.azurerm_dns_zone.subdomain[0].name
  resource_group_name = data.azurerm_resource_group.dns.name

  name = "@"

  ttl                = 300
  target_resource_id = azurerm_public_ip.aks_public_lb.id
}

resource "azurerm_dns_a_record" "eks_public_ingress_api" {
  count = 1

  zone_name           = data.azurerm_dns_zone.subdomain[0].name
  resource_group_name = data.azurerm_resource_group.dns.name

  name = "api"

  ttl                = 300
  target_resource_id = azurerm_public_ip.aks_public_lb.id
}

##
# Private Ingress
##
resource "azurerm_dns_a_record" "eks_private_ingress" {
  count = 1

  zone_name           = data.azurerm_dns_zone.subdomain[0].name
  resource_group_name = data.azurerm_resource_group.dns.name

  name = "k8s"

  ttl     = 300
  records = [""]
}

resource "azurerm_dns_a_record" "eks_private_ingress_wildcard" {
  count = 1

  zone_name           = data.azurerm_dns_zone.subdomain[0].name
  resource_group_name = data.azurerm_resource_group.dns.name

  name = "*.k8s"

  ttl     = 300
  records = [""]
}

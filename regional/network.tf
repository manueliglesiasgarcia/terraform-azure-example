module "network" {
  source  = "Azure/network/azurerm"
  version = "3.3.0"

  vnet_name = module.dev_envs.azure_environments[terraform.workspace]["environment-name"]

  resource_group_name = azurerm_resource_group.root.name
  address_space       = module.dev_envs.azure_environments[terraform.workspace]["network"]["cidr"]
  subnet_prefixes     = module.dev_envs.azure_environments[terraform.workspace]["network"]["subnets_address_space"]
  subnet_names        = module.dev_envs.azure_environments[terraform.workspace]["network"]["subnets_names"]

  subnet_enforce_private_link_endpoint_network_policies = module.dev_envs.azure_environments[terraform.workspace]["network"]["subnet_enforce_private_link_endpoint_network_policies"]

  tags = local.common_tags

  depends_on = [azurerm_resource_group.root]
}

resource "azurerm_public_ip" "nat_gateway" {
  name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-natgateway-publicip"

  location            = azurerm_resource_group.root.location
  resource_group_name = azurerm_resource_group.root.name

  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1"]
}

resource "azurerm_public_ip_prefix" "nat_gateway" {
  name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-natgateway-publicipprefix"

  location            = azurerm_resource_group.root.location
  resource_group_name = azurerm_resource_group.root.name

  prefix_length = 30
  zones         = ["1"]
}

resource "azurerm_nat_gateway" "root" {
  name = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-natgateway"

  location            = azurerm_resource_group.root.location
  resource_group_name = azurerm_resource_group.root.name

  public_ip_prefix_ids = [azurerm_public_ip_prefix.nat_gateway.id]

  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "root" {
  nat_gateway_id       = azurerm_nat_gateway.root.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "root" {
  for_each = toset(slice(module.network.vnet_subnets, 0, 3))

  subnet_id      = each.value
  nat_gateway_id = azurerm_nat_gateway.root.id
}

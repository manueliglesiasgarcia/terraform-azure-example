resource "azurerm_resource_group" "root" {
  name     = module.dev_envs.azure_environments[terraform.workspace]["environment-name"]
  location = module.dev_envs.azure_environments[terraform.workspace]["region"]

  tags = local.common_tags
}

data "azurerm_resource_group" "dns" {
  name = "${azurerm_resource_group.root.name}-dns"
}

data "azurerm_resource_group" "vault" {
  name = "${azurerm_resource_group.root.name}-vault"
}

data "azurerm_key_vault" "root" {
  name                = "test-${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}"
  resource_group_name = data.azurerm_resource_group.vault.name
}

data "azurerm_key_vault_certificate" "app_gateway_certs" {
  for_each = module.dev_envs.azure_environments[terraform.workspace]["application-gateway"]["ssl-certs-hostnames"]

  name         = each.key
  key_vault_id = data.azurerm_key_vault.root.id
}

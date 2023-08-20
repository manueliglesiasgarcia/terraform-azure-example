module "aks" {
  source  = "Azure/aks/azurerm"
  version = "4.10.0"

  resource_group_name = azurerm_resource_group.root.name

  client_id     = data.azurerm_key_vault_secret.aks_serviceprincipal_appid.value
  client_secret = data.azurerm_key_vault_secret.aks_serviceprincipal_password.value

  kubernetes_version   = "1.22.6"
  orchestrator_version = "1.22.6"

  prefix         = module.dev_envs.azure_environments[terraform.workspace]["environment-name"]
  network_plugin = "azure"

  vnet_subnet_id  = module.network.vnet_subnets[0]
  os_disk_size_gb = 100
  sku_tier        = "Free"

  enable_role_based_access_control = true
  rbac_aad_managed                 = true

  private_cluster_enabled         = false
  enable_azure_policy             = false
  enable_http_application_routing = false
  enable_log_analytics_workspace  = false
  enable_auto_scaling             = true

  agents_min_count          = 10
  agents_max_count          = 18
  agents_max_pods           = 100
  agents_pool_name          = replace("${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-aks", "-", "")
  agents_availability_zones = ["1", "2", "3"]
  agents_type               = "VirtualMachineScaleSets"
  agents_size               = "Standard_E4s_v4"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.50.0.10"
  net_profile_docker_bridge_cidr = "172.18.0.1/16"
  net_profile_service_cidr       = "10.50.0.0/16"

  depends_on = [module.network]
}

data "azurerm_key_vault_secret" "aks_serviceprincipal_appid" {
  name         = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-aks-serviceprincipal-appid"
  key_vault_id = data.azurerm_key_vault.root.id
}

data "azurerm_key_vault_secret" "aks_serviceprincipal_password" {
  name         = "${module.dev_envs.azure_environments[terraform.workspace]["environment-name"]}-aks-serviceprincipal-password"
  key_vault_id = data.azurerm_key_vault.root.id
}

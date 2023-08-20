resource "azurerm_container_registry" "acr_eun_prod" {
  name                     = "acr"

  resource_group_name      = azurerm_resource_group.eun_prod.name
  location                 = azurerm_resource_group.eun_prod.location
  
  sku                      = "Premium"
  admin_enabled            = true

  georeplication_locations = ["Japan West"]
}
resource "azurerm_resource_group" "env_tfstate" {
  name     = "env-tfstate"
  location = "North Europe"
}

resource "azurerm_storage_account" "env_tfstate" {
  name                     = "envtfstate"
  resource_group_name      = azurerm_resource_group.env_tfstate.name
  location                 = azurerm_resource_group.env_tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "production"
    terraform = "true"
    owner = "devops"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.env_tfstate.name
  container_access_type = "private"
}
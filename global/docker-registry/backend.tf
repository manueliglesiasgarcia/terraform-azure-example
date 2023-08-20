terraform {
  backend "azurerm" {
    subscription_id = ""
    tenant_id       = ""

    resource_group_name  = "env-tfstate"
    storage_account_name = "envtfstate"
    container_name       = "tfstate"
    key                  = "env-docker-registry.terraform.tfstate"
  }
}

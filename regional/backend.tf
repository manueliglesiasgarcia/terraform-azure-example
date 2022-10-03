terraform {
  backend "azurerm" {
    subscription_id = ""
    tenant_id       = ""

    resource_group_name  = "test-tfstate"
    storage_account_name = "testtfstate"
    container_name       = "tfstate"
    key                  = "test.terraform.tfstate"
  }
}

terraform {
  required_version = ">= 0.13.0"
}

provider "azurerm" {
  alias = "hmcts-control"
  features {}
}



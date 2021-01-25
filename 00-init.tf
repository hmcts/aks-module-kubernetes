terraform {
  required_version = ">= 0.13.0"
}

provider "azurerm" {
  alias = "hmcts-control"
}

provider "azurerm" {
  alias = "acr"
}

provider "azurerm" {
  alias = "global_acr"
}

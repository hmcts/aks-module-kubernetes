terraform {
  required_version = ">= 1.2.2"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.hmcts-control, azurerm.acr, azurerm.global_acr]
      version               = "4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.15.0"
    }
  }
}

provider "azurerm" {
  alias = "global_acr"
}

provider "azurerm" {
  alias = "hmcts-control"
  # Include any necessary authentication details if required
}

provider "azurerm" {
  alias = "acr"
  # Include any necessary authentication details if required
}


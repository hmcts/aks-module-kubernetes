terraform {
  required_version = ">= 1.2.2"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.hmcts-control, azurerm.acr, azurerm.global_acr]
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.15.0"
    }
  }
}

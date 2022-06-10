terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "3.10.0"
      configuration_aliases = [azurerm.hmcts-control, azurerm.acr, azurerm.global_acr]
    }
  }
}

terraform {
  required_version = ">= 1.2.2"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "3.10.0"
      configuration_aliases = [azurerm.hmcts-control, azurerm.acr, azurerm.global_acr]
    }
  }
}

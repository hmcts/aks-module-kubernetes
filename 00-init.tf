terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.57.0"
      configuration_aliases = [ azurerm.hmcts-control, azurerm.acr, azurerm.global_acr  ]
    }
  }
}

# terraform {
  
# }

# provider "azurerm" {
#   alias = "hmcts-control"
# }

# provider "azurerm" {
#   alias = "acr"
# }

# provider "azurerm" {
#   alias = "global_acr"
# }

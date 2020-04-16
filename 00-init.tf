terraform {
  required_version = ">= 0.12.0"
}

provider "azurerm" {
  alias = "hmcts-control"
  skip_provider_registration = "true"
  version         = "= 2.5.0"
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}
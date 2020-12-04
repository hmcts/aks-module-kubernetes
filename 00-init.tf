terraform {
  required_version = ">= 0.13.0"
}

provider "azurerm" {
  alias = "hmcts-control"
  features {}
}

provider "azurerm" {
  features {}
  alias           = "loganalytics"
  subscription_id = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.environment)][0]].subscription_id
}

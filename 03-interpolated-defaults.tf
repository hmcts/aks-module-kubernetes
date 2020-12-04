data "azurerm_subscription" "subscription" {}

data "azurerm_role_definition" "builtin_role_definition" {
  name  = "Contributor"
  scope = data.azurerm_subscription.subscription.id
}

locals {
  slug_location = lower(replace(var.location, " ", "."))
}

data "azurerm_log_analytics_workspace" "ss-law" {
  provider            = azurerm.loganalytics
  name                = local.log_analytics_workspace[[for x in keys(local.log_analytics_env_mapping) : x if contains(local.log_analytics_env_mapping[x], var.environment)][0]].name
  resource_group_name = "oms-automation"
}

data "azurerm_subnet" "aks" {
  name = format("%s-%s",
    var.service_shortname,
    var.cluster_number
  )

  virtual_network_name = var.network_name
  resource_group_name  = var.network_resource_group_name
}

data "azurerm_key_vault" "hmcts_access_vault" {
  provider            = azurerm.hmcts-control
  name                = var.control_vault
  resource_group_name = "azure-control-${var.environment}-rg"
}

data "azurerm_key_vault_secret" "aks_admin_group_id" {
  provider     = azurerm.hmcts-control
  name         = "aks-admin-rbac-group-id"
  key_vault_id = data.azurerm_key_vault.hmcts_access_vault.id
}

data "azurerm_key_vault_secret" "kubernetes_cluster_client_secret" {
  provider     = azurerm.hmcts-control
  name         = "sp-token"
  key_vault_id = data.azurerm_key_vault.hmcts_access_vault.id
}

data "azurerm_client_config" "current" {}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "subscription" {}

data "azurerm_role_definition" "builtin_role_definition" {
  name  = "Contributor"
  scope = data.azurerm_subscription.subscription.id # /subscriptions/00000000-0000-0000-0000-000000000000
}

data "null_data_source" "tag_defaults" {
  inputs = {
    Project_Name         = var.tag_project_name
    Environment          = var.tag_environment
    Cost_Center          = var.tag_cost_center
    Service              = var.tag_service
    App_Operations_Owner = var.tag_app_operations_owner
    System_Owner         = var.tag_system_owner
    Budget_Owner         = var.tag_budget_owner
    Created_By           = "Terraform"
  }
}

locals {
  slug_location = lower(replace(var.location, " ", "."))
}

data "azurerm_log_analytics_workspace" "ss-law" {
  name = format("%s_%s_law",
    var.service_name_prefix,
    var.deploy_environment
  )

  resource_group_name  = format("%s_%s_monitoring_rg",
    var.service_name_prefix,
    var.deploy_environment
  )
}

data "azurerm_subnet" "aks" {
  name = format("%s_%s_%s",
    var.network_shortname,
    var.cluster_number,
    var.deploy_environment
  )

  virtual_network_name = var.network_name
  resource_group_name  = var.network_resource_group_name
}

data "azurerm_subnet" "aks_01" {
  name = format("%s_01_%s",
    var.network_shortname,
    var.deploy_environment
  )

  virtual_network_name = var.network_name
  resource_group_name  = var.network_resource_group_name
}

data "azurerm_subnet" "iaas" {
  name = format("%s_iaas_%s",
    var.network_shortname,
    var.deploy_environment
  )

  virtual_network_name = var.network_name
  resource_group_name  = var.network_resource_group_name
}

data "azurerm_subnet" "application_gateway" {
  name = format("%s_application_gateway_%s",
    var.network_shortname,
    var.deploy_environment
  )

  virtual_network_name = var.network_name
  resource_group_name  = var.network_resource_group_name
}

data "azurerm_key_vault" "hmcts_access_vault" {
  provider            = azurerm.hmcts-control
  name                = var.hmcts_access_vault
  resource_group_name = "azure-control-${var.deploy_environment}-rg"
}

data "azurerm_key_vault_secret" "kubernetes_aad_client_app_id" {
  provider            = azurerm.hmcts-control
  name                = "${var.service_shortname}-client-application-id"
  key_vault_id        = data.azurerm_key_vault.hmcts_access_vault.id
}

data "azurerm_key_vault_secret" "kubernetes_aad_server_app_id" {
  provider            = azurerm.hmcts-control
  name                = "${var.service_shortname}-server-application-id"
  key_vault_id        = data.azurerm_key_vault.hmcts_access_vault.id
}

data "azurerm_key_vault_secret" "kubernetes_aad_server_app_secret" {
  provider            = azurerm.hmcts-control
  name                = "${var.service_shortname}-server-token"
  key_vault_id        = data.azurerm_key_vault.hmcts_access_vault.id
}

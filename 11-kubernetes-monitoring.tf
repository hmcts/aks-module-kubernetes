#--------------------------------------------------------------
# Azure Log Analytics
#--------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name = format(
    "%s-%s-%s-law",
    var.service_name_prefix,
    var.service_shortname,
    data.null_data_source.tag_defaults.inputs["Environment"],
  )

  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.kubernetes_cluster_log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "log_analytics_solution" {
  solution_name = "ContainerInsights"

  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = var.kubernetes_cluster_log_analytics_solution_publisher
    product   = var.kubernetes_cluster_log_analytics_solution_product
  }
}


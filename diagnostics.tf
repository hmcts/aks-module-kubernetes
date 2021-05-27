data "azurerm_resource_group" "project_acr" {
  provider = azurerm.acr
  name = format("%s-acr-rg",
    local.acr[var.project].resource_group_prefix,
  )

  count = var.project_acr_enabled ? 1 : 0
}


resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "DiagLogAnalytics"
  count                      = var.monitor_diagnostic_setting ? 1 : 0
  target_resource_id         = data.azurerm_kubernetes_cluster.kubernetes_cluster.id
  log_analytics_workspace_id = var.log_workspace_id

  log {
    category = "kube-apiserver"
    enabled  = true

    # retention_policy {
    #   enabled = false
    # }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    # retention_policy {
    #   enabled = false
    # }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    # retention_policy {
    #   enabled = false
    # }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    # retention_policy {
    #   enabled = false
    # }
  }

  log {
    category = "kube-audit"
    enabled  = true

    # retention_policy {
    #   enabled = false
    # }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

}
resource "azurerm_monitor_diagnostic_setting" "kubernetes_cluster_diagnostic_setting" {
  name                       = "DiagLogAnalytics"
  count                      = var.monitor_diagnostic_setting ? 1 : 0
  target_resource_id         = azurerm_kubernetes_cluster.kubernetes_cluster.id
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
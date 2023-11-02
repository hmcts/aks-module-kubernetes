resource "azurerm_monitor_diagnostic_setting" "kubernetes_cluster_diagnostic_setting" {
  name                           = "DiagLogAnalytics"
  count                          = var.monitor_diagnostic_setting ? 1 : 0
  target_resource_id             = azurerm_kubernetes_cluster.kubernetes_cluster.id
  log_analytics_workspace_id     = var.log_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "guard"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "kube-scheduler"
  }
}

resource "azurerm_monitor_diagnostic_setting" "metrics_diagnostic_setting" {
  name                           = "Metrics"
  count                          = var.monitor_diagnostic_setting_metrics ? 1 : 0
  target_resource_id             = azurerm_kubernetes_cluster.kubernetes_cluster.id
  log_analytics_workspace_id     = var.log_workspace_id
  log_analytics_destination_type = "Dedicated"

  metric {
    category = "AllMetrics"
  }
}

locals {
  businessArea = var.project == "ss" ? "sds" : var.project
}

data "azurerm_storage_account" "diagnostics" {
  count = var.kube_audit_admin_logs_enabled ? 1 : 0

  name                = "hmcts${local.businessArea}diag${var.environment}"
  resource_group_name = "lz-${var.environment}-rg"
}

resource "azurerm_monitor_diagnostic_setting" "kubernetes_cluster_diagnostic_setting_sa" {
  name               = "aks-storage"
  count              = var.kube_audit_admin_logs_enabled ? 1 : 0
  target_resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  storage_account_id = data.azurerm_storage_account.diagnostics[0].id

  enabled_log {
    category = "kube-audit-admin"
  }
}

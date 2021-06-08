locals {
  acr = {
    ss = {
      resource_group_prefix = "sds"
    }
    cft = {
      resource_group_prefix = "cnp"
    }
  }
}

// ==================
// Project ACR
// ==================

data "azurerm_resource_group" "project_acr" {
  provider = azurerm.mi_cft
  name = format("%s-acr-rg",
    local.acr[var.project].resource_group_prefix,
  )

  count = var.project_acr_enabled ? 1 : 0
}


resource "azurerm_role_assignment" "project_acrpull" {
  provider             = azurerm.mi_cft
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_resource_group.project_acr[0].id

  count = var.project_acr_enabled ? 1 : 0
}

// ==================
// Global ACR (hmctspublic / hmctsprivate)
// ==================

data "azurerm_resource_group" "global_acr" {
  provider = azurerm.global_acr
  name     = "rpe-acr-prod-rg"

  count = var.global_acr_enabled ? 1 : 0
}

resource "azurerm_role_assignment" "global_registry_acrpull" {
  # AKS SP ACR Pull role
  provider             = azurerm.global_acr
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.global_acr[0].id

  count = var.global_acr_enabled ? 1 : 0
}

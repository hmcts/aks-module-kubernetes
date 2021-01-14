locals {
  acr = {
    ss = {
      subscription          = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
      resource_group_prefix = "sds"
    }
    global = {
      subscription          = "8999dec3-0104-4a27-94ee-6588559729d1"
      resource_group_prefix = "rpe"
    }
  }
}

// ==================
// Project ACR
// ==================

data "azurerm_resource_group" "project_acr" {
  provider = azurerm.acr
  name = format("%s-acr-rg",
    local.acr[var.project].resource_group_prefix,
  )

  count = var.project_acr_enabled ? 1 : 0
}


resource "azurerm_role_assignment" "project_acrpull" {
  provider             = azurerm.acr
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
  name = format("%s-acr-rg",
    local.acr["global"].resource_group_prefix,
  )

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

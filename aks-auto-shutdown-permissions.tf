resource "azurerm_role_assignment" "aks_auto_shutdown" {
  count = var.aks_auto_shutdown_principal_id == "" ? 0 : 1

  principal_id         = var.aks_auto_shutdown_principal_id
  scope                = azurerm_kubernetes_cluster.kubernetes_cluster.id
  role_definition_name = "Contributor"
}

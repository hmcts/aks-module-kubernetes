resource "azurerm_role_assignment" "update_checker" {
  count = var.aks_version_checker_principal_id == "" ? 0 : 1

  principal_id         = var.aks_version_checker_principal_id
  scope                = azurerm_kubernetes_cluster.kubernetes_cluster.id
  role_definition_name = "Reader"
}

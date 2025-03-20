resource "azurerm_federated_identity_credential" "service_operator_credential" {
  depends_on          = [data.azurerm_user_assigned_identity.aks]
  name                = "${var.project}-${var.environment}-${var.cluster_number}-${var.service_shortname}"
  resource_group_name = var.aks_mi_resource_group_name
  issuer              = azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
  audience            = ["api://AzureADTokenExchange"]
  parent_id           = data.azurerm_user_assigned_identity.aks.id
  subject             = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
}
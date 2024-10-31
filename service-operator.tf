resource "azurerm_federated_identity_credential" "service_operator_credential" {
  name                = "${var.project}-${var.environment}-${var.cluster_number}-${var.service_shortname}"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
  parent_id           = data.azurerm_user_assigned_identity.aks.id
  subject             = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
}

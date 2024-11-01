resource "azapi_resource" "service_operator_credential" {
  count               = var.environment == "sbox" ? 0 : 1
  schema_validation_enabled = false
  name                      = "${var.project}-${var.environment}-${var.cluster_number}-${var.service_shortname}"
  parent_id                 = data.azurerm_user_assigned_identity.aks.id
  type                      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2022-01-31-preview"
  location                  = var.location
  body = jsonencode({
    properties = {
      issuer    = azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
      subject   = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
      audiences = ["api://AzureADTokenExchange"]
    }
  })
  lifecycle {
    ignore_changes = [location]
  }
}

resource "azurerm_federated_identity_credential" "service_operator_credential" {
  count               = var.environment == "sbox" ? 1 : 0
  name                = "${var.project}-${var.environment}-${var.cluster_number}-${var.service_shortname}"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
  parent_id           = data.azurerm_user_assigned_identity.aks.id
  subject             = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
}

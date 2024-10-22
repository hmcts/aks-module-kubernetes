resource "azapi_resource" "service_operator_credential" {
  schema_validation_enabled = false
  name                      = "${var.project}-${var.environment}-${var.cluster_number}-${var.service_shortname}"
  parent_id                 = data.azurerm_user_assigned_identity.aks.id
  type                      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2022-01-31-preview"
  location                  = var.location
  body = {
    properties = {
      issuer    = azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
      subject   = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
      audiences = ["api://AzureADTokenExchange"]
    }
  }
  lifecycle {
    ignore_changes = [location]
  }
}

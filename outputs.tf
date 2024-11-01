output "cluster" {
  value = var.cluster_number
}

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
}

output "aks_user_assigned_identity_id" {
  value = data.azurerm_user_assigned_identity.aks.id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
}

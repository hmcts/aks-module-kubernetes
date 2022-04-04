output "cluster" {
  value = var.cluster_number
}

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
}

output "kubelet_identity" {
  value = {
    user_assigned_identity_id = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].user_assigned_identity_id
  }
}
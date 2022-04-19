output "cluster" {
  value = var.cluster_number
}

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
}


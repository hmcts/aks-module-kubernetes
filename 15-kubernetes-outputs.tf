data "null_data_source" "kubernetes_cluster_outputs" {
  inputs = {
    kubernetes_cluster_resource_group      = var.resource_group_name
    kubernetes_cluster_id                  = azurerm_kubernetes_cluster.kubernetes_cluster.id
    kubernetes_cluster_fqdn                = azurerm_kubernetes_cluster.kubernetes_cluster.fqdn
    kubernetes_cluster_node_resource_group = azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group

    // may not be needed

    // kubenetes_cluster_kube_config            = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config_raw}"
    // kubenetes_cluster_client_key             = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_key}"
    // kubenetes_cluster_client_certificate     = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_certificate}"
    // kubenetes_cluster_cluster_ca_certificate = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.cluster_ca_certificate}"
    // kubenetes_cluster_host                   = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.host}"
    // kubenetes_cluster_username               = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.username}"
    // kubenetes_cluster_password               = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.password}"
  }
}

output "kubernetes_cluster_result" {
  value = data.null_data_source.kubernetes_cluster_outputs.inputs
}

output "kubernetes_cluster_result_json" {
  value = jsonencode(data.null_data_source.kubernetes_cluster_outputs.inputs)
}

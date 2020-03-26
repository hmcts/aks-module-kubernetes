data "null_data_source" "kubernetes_cluster_debug_outputs" {
  count = var.enable_debug == "true" ? 1 : 0

  inputs = {
    # inputs-required
    deploy_environment                = var.deploy_environment
    network_name                      = var.network_name
    network_shortname                 = var.network_shortname
    network_resource_group_name       = var.network_resource_group_name
    service_shortname                 = var.service_shortname
    service_name_prefix               = var.service_name_prefix
    resource_group_name               = var.resource_group_name
    location                          = var.location
    kubernetes_cluster_admin_username = var.kubernetes_cluster_admin_username
    kubernetes_cluster_ssh_key        = var.kubernetes_cluster_ssh_key
    kubernetes_cluster_client_id      = var.kubernetes_cluster_client_id
    kubernetes_cluster_client_secret  = var.kubernetes_cluster_client_secret

    # inputs-default
    enable_debug = var.enable_debug
  }
}

output "kubernetes_cluster_debug_config" {
  value = data.null_data_source.kubernetes_cluster_debug_outputs.*.inputs
}

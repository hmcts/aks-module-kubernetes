#--------------------------------------------------------------
# Kubernetes Cluster
#--------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  location            = var.location
  resource_group_name = var.resource_group_name

  name = format("%s-%s-%s-%s",
    var.project,
    var.environment,
    var.cluster_number,
    var.service_shortname
  )

  node_resource_group = format("%s-%s-%s-%s-node-rg",
    var.project,
    var.environment,
    var.cluster_number,
    var.service_shortname
  )

  default_node_pool {
    name                = "nodepool"
    vm_size             = var.kubernetes_cluster_agent_vm_size
    enable_auto_scaling = var.kubernetes_cluster_enable_auto_scaling
    max_pods            = var.kubernetes_cluster_agent_max_pods
    os_disk_size_gb     = var.kubernetes_cluster_agent_os_disk_size
    type                = var.kubernetes_cluster_agent_type
    vnet_subnet_id      = data.azurerm_subnet.aks.id
    max_count           = var.kubernetes_cluster_agent_max_count
    min_count           = var.kubernetes_cluster_agent_min_count
  }

  dns_prefix = format("k8s-%s-%s-%s",
    var.project,
    var.environment,
    var.service_shortname,
  )

  service_principal {
    client_id     = data.azurerm_client_config.current.client_id
    client_secret = data.azurerm_key_vault_secret.kubernetes_cluster_client_secret.value
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id =  var.log_workspace_id
    }
  }

  kubernetes_version = var.kubernetes_cluster_version

  linux_profile {
    admin_username = var.kubernetes_cluster_admin_username

    ssh_key {
      key_data = var.kubernetes_cluster_ssh_key
    }
  }

  network_profile {
    network_plugin    = var.kubernetes_cluster_network_plugin
    load_balancer_sku = var.kubernetes_cluster_load_balancer_sku
  }

  role_based_access_control {
    enabled = var.kubernetes_cluster_rbac_enabled

    azure_active_directory {
      managed                = true
      admin_group_object_ids = [var.global_aks_admins_group_object_id, data.azurerm_key_vault_secret.aks_admin_group_id.value]
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      windows_profile,
      default_node_pool["max_count"],
    ]
  }
}

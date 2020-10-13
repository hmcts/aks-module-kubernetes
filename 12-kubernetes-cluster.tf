#--------------------------------------------------------------
# Kubernetes Cluster
#--------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  location            = var.location
  resource_group_name = var.resource_group_name

  name = format("%s-%s-%s-%s",
    var.service_name_prefix,
    lookup(data.null_data_source.tag_defaults.inputs, "Environment"),
    var.cluster_number,
    var.service_shortname
  )

  node_resource_group = format("%s-%s-%s-%s-node-rg",
    var.service_name_prefix,
    lookup(data.null_data_source.tag_defaults.inputs, "Environment"),
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
    var.service_name_prefix,
    lookup(data.null_data_source.tag_defaults.inputs, "Environment"),
    var.service_shortname,
  )

  service_principal {
    client_id     = var.kubernetes_cluster_client_id
    client_secret = var.kubernetes_cluster_client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.ss-law.id
    }

    kube_dashboard {
      enabled = var.kubernetes_cluster_kube_dashboard_enabled
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
      managed = true
      admin_group_object_ids = var.cluster_admin_aad_object_ids
    }
  }

  tags = merge(
    data.null_data_source.tag_defaults.inputs,
    map(
      "Name", replace(
        format("%s-%s-%s",
          var.service_name_prefix,
          var.service_shortname,
          lookup(data.null_data_source.tag_defaults.inputs, "Environment")
        ),
        "_",
        "-"
      )
    )
  )
  lifecycle {
    ignore_changes = [windows_profile]
  }
}

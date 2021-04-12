#--------------------------------------------------------------
# Kubernetes Cluster
#--------------------------------------------------------------

data "azurerm_resource_group" "genesis_rg" {
  name = "genesis-rg"
}

data "azurerm_resource_group" "managed-identity-operator" {
  name = "managed-identities-${var.environment}-rg"
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "aks-${var.environment}-mi"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

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
    os_disk_type        = "Ephemeral"
  }

  dns_prefix = format("k8s-%s-%s-%s",
    var.project,
    var.environment,
    var.service_shortname,
  )

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = data.azurerm_user_assigned_identity.aks.id
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_workspace_id
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
    ]
  }
}

resource "azurerm_role_assignment" "genesis_managed_identity_operator" {
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_user_assigned_identity.aks.id
  role_definition_name = "Managed Identity Operator"
}

resource "azurerm_role_assignment" "uami_rg_identity_operator" {
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.managed-identity-operator.id
  role_definition_name = "Managed Identity Operator"
}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
}

resource "azurerm_kubernetes_cluster_node_pool" "additional_node_pools" {
  for_each = { for np in var.additional_node_pools : np.name => np }

  name                  = var.additional_node_pools.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  vm_size               = lookup(var.additional_node_pools, "vm_size", var.kubernetes_cluster_agent_vm_size)
  enable_auto_scaling   = lookup(var.additional_node_pools, "enable_auto_scaling", var.kubernetes_cluster_enable_auto_scaling)
  min_count             = var.additional_node_pools.min_count
  max_count             = var.additional_node_pools.max_count
  os_type               = lookup(var.additional_node_pools, "os_type", "Linux")
  os_disk_type          = "Ephemeral"
  node_taints           = var.additional_node_pools.node_taints
}
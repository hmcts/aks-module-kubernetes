#--------------------------------------------------------------
# Kubernetes Cluster
#--------------------------------------------------------------

locals {
  node_resource_group = "${var.project}-${var.environment}-${var.cluster_number}-${var.service_shortname}-node-rg"
}

data "azurerm_resource_group" "genesis_rg" {
  name = "genesis-rg"
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "aks-${var.environment}-mi"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name
}

data "azurerm_user_assigned_identity" "kubelet_uami" {
  name                = "aks-kubelet-${var.environment}-mi"
  resource_group_name = data.azurerm_resource_group.genesis_rg.name

  count = var.kubelet_uami_enabled ? 1 : 0
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

  node_resource_group = local.node_resource_group

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_policy_enabled      = var.azure_policy_enabled

  sku_tier = var.sku_tier
  default_node_pool {
    name                         = var.enable_user_system_nodepool_split == true ? "system" : "nodepool"
    only_critical_addons_enabled = var.enable_user_system_nodepool_split == true ? true : false
    vm_size                      = var.kubernetes_cluster_agent_vm_size
    enable_auto_scaling          = var.kubernetes_cluster_enable_auto_scaling
    max_pods                     = var.kubernetes_cluster_agent_max_pods
    os_disk_size_gb              = var.kubernetes_cluster_agent_os_disk_size
    type                         = var.kubernetes_cluster_agent_type
    vnet_subnet_id               = data.azurerm_subnet.aks.id
    max_count                    = var.kubernetes_cluster_agent_max_count
    min_count                    = var.kubernetes_cluster_agent_min_count
    os_disk_type                 = "Ephemeral"
    orchestrator_version         = var.kubernetes_cluster_version
    tags                         = var.tags
    zones                        = var.availability_zones
  }

  dns_prefix = format("k8s-%s-%s-%s",
    var.project,
    var.environment,
    var.service_shortname,
  )

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aks.id]
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_uami_enabled != false ? [1] : []
    content {
      client_id                 = data.azurerm_user_assigned_identity.kubelet_uami[0].client_id
      object_id                 = data.azurerm_user_assigned_identity.kubelet_uami[0].principal_id
      user_assigned_identity_id = data.azurerm_user_assigned_identity.kubelet_uami[0].id
    }
  }

  dynamic "oms_agent" {
    for_each = var.oms_agent_enabled != false ? [1] : []
    content {
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

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = false
    managed                = true
    admin_group_object_ids = [var.global_aks_admins_group_object_id, data.azurerm_key_vault_secret.aks_admin_group_id.value]
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.csi_driver_enabled != false ? [1] : []

    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = "5m"
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      windows_profile,
    ]
    precondition {
      // Error if enable_automatic_channel_upgrade_patch is true and the Kubernetes version includes the patch version
      condition     = var.enable_automatic_channel_upgrade_patch != true || can(regex("^1\\.\\d\\d$", var.kubernetes_cluster_version))
      error_message = "When automatic upgrades are enabled, kubernetes_cluster_version must only include major and minor versions, not the patch version e.g. 1.18 or 1.25"
    }
    # precondition {
    #   condition     = var.node_os_maintenance_window_duration >= 4 || var.node_os_maintenance_window_duration == null
    #   error_message = "Duration must be at least 4 hours long"
    # }
  }

  automatic_channel_upgrade = var.enable_automatic_channel_upgrade_patch == true ? "patch" : null
  node_os_channel_upgrade   = var.enable_node_os_channel_upgrade_nodeimage == true ? "NodeImage" : null

  dynamic "maintenance_window_node_os" {
    for_each = var.enable_node_os_channel_upgrade_nodeimage != false ? [1] : [0]
    content {
      duration   = var.node_os_maintenance_window_duration
      frequency  = var.node_os_maintenance_window_frequency
      interval   = var.node_os_maintenance_window_interval
      start_time = var.node_os_maintenance_window_start_time
      utc_offset = var.node_os_maintenance_window_utc_offset
      start_date = var.node_os_maintenance_window_start_date
    }
  }
}

resource "azurerm_role_assignment" "genesis_managed_identity_operator" {
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_user_assigned_identity.aks.id
  role_definition_name = "Managed Identity Operator"

  count = var.kubelet_uami_enabled ? 0 : 1
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id

  # https://github.com/hmcts/aks-module-kubernetes/pull/81
  # Semi hard-coded scope to remove dependency on getting the ID for the node resource group from the attributes
  # of the cluster resource causing role assignments to be recreated and sometimes having to be 
  # recreated manually.
  scope                = "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}/resourceGroups/${local.node_resource_group}"
  role_definition_name = "Virtual Machine Contributor"
}

resource "azurerm_kubernetes_cluster_node_pool" "additional_node_pools" {
  for_each = { for np in var.additional_node_pools : np.name => np }

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  vm_size               = lookup(each.value, "vm_size", var.kubernetes_cluster_agent_vm_size)
  enable_auto_scaling   = lookup(each.value, "enable_auto_scaling", var.kubernetes_cluster_enable_auto_scaling)
  mode                  = lookup(each.value, "mode", "User")
  priority              = lookup(each.value, "priority", "Regular")
  spot_max_price        = lookup(each.value, "spot_max_price", "-1")
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  max_pods              = lookup(each.value, "max_pods", "30")
  os_type               = lookup(each.value, "os_type", "Linux")
  os_disk_type          = "Ephemeral"
  node_taints           = each.value.node_taints
  orchestrator_version  = var.kubernetes_cluster_version
  vnet_subnet_id        = data.azurerm_subnet.aks.id
  tags                  = var.tags
  zones                 = var.availability_zones

  dynamic "upgrade_settings" {
    for_each = each.value.name != "spotinstance" ? [1] : []
    content {
      max_surge = var.upgrade_max_surge
    }
  }
  timeouts {
    update = "180m"
  }

}

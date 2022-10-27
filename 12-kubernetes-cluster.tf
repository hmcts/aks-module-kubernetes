#--------------------------------------------------------------
# Kubernetes Cluster
#--------------------------------------------------------------

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

data "azurerm_resource_group" "managed-identity-operator" {
  name = "managed-identities-${var.environment}-rg"
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

  oidc_issuer_enabled       = true
  workload_identity_enabled = var.workload_identity_enabled

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
  }

  automatic_channel_upgrade = var.enable_automatic_channel_upgrade_patch == true ? "patch" : null

}

resource "azurerm_role_assignment" "genesis_managed_identity_operator" {
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_user_assigned_identity.aks.id
  role_definition_name = "Managed Identity Operator"

  count = var.kubelet_uami_enabled ? 0 : 1
}

resource "azurerm_role_assignment" "uami_rg_identity_operator" {
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.managed-identity-operator.id
  role_definition_name = "Managed Identity Operator"

  count = var.kubelet_uami_enabled ? 0 : 1
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

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  vm_size               = lookup(each.value, "vm_size", var.kubernetes_cluster_agent_vm_size)
  enable_auto_scaling   = lookup(each.value, "enable_auto_scaling", var.kubernetes_cluster_enable_auto_scaling)
  mode                  = lookup(each.value, "mode", "User")
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

  upgrade_settings {
    max_surge = var.upgrade_max_surge
  }
}

data "azurerm_resource_group" "disks_resource_group" {
  name = "disks-${var.environment}-rg"
}

resource "azurerm_role_assignment" "disks_resource_group_role_assignment" {
  count                = var.ptl_cluster ? 1 : 0
  principal_id         = data.azurerm_user_assigned_identity.aks.principal_id
  scope                = data.azurerm_resource_group.disks_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
}

resource "azurerm_monitor_diagnostic_setting" "kubernetes_cluster_diagnostic_setting" {
  name                       = "DiagLogAnalytics"
  count                      = var.monitor_diagnostic_setting ? 1 : 0
  target_resource_id         = azurerm_kubernetes_cluster.kubernetes_cluster.id
  log_analytics_workspace_id = var.log_workspace_id

  log {
    category = "kube-apiserver"
    enabled  = true
  }


  log {
    category = "guard"
    enabled  = true
  }

  log {
    category = "kube-controller-manager"
    enabled  = true
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true
  }

  log {
    category = "kube-scheduler"
    enabled  = true
  }

  log {
    category = "kube-audit-admin"
    enabled  = var.environment == "prod" ? true : false
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

}

# Azure Service Operator federated identity credential and role assignment

resource "azurerm_role_assignment" "Contributor" {
  principal_id         = data.azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Contributor"
  scope                = data.azurerm_subscription.subscription.id
}

resource "azapi_resource" "federated_identity_credential" {
  schema_validation_enabled = false
  name = format("%s-%s-%s-%s",
    var.project,
    var.environment,
    var.cluster_number,
    var.service_shortname
  )
  parent_id = data.azurerm_user_assigned_identity.aks.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2022-01-31-preview"
  location  = var.location
  body = jsonencode({
    properties = {
      issuer    = azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
      subject   = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-system"
      audiences = ["api://AzureADTokenExchange"]
    }
  })
  lifecycle {
    ignore_changes = [location]
  }
}

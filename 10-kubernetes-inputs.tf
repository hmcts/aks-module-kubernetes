variable "kubernetes_cluster_load_balancer_sku" {
  default = "standard"
}

variable "kubernetes_cluster_agent_max_count" {
  default = 6
}

variable "kubernetes_cluster_agent_min_count" {
  default = 1
}

variable "kubernetes_cluster_agent_vm_size" {
  default = "Standard_DS3_v2"
}

variable "kubernetes_cluster_agent_max_pods" {
  default = "50"
}

variable "kubernetes_cluster_agent_os_disk_size" {
  default = "128"
}

variable "kubernetes_cluster_agent_os_type" {
  default = "Linux"
}

variable "kubernetes_cluster_http_application_routing" {
  default = false
}

variable "kubernetes_cluster_enable_auto_scaling" {
  default = true
}

variable "kubernetes_cluster_version" {
  default = "1.18.8"
}

variable "kubernetes_cluster_network_plugin" {
  default = "azure"
}

variable "kubernetes_cluster_network_policy" {
  default = "azure"
}

variable "kubernetes_cluster_agent_type" {
  default = "VirtualMachineScaleSets"
}

variable "kubernetes_cluster_identity_type" {
  default = "SystemAssigned"
}

variable "kubernetes_cluster_rbac_enabled" {
  default = "true"
}

variable "global_aks_admins_group_object_id" {
  default = "a6ce5b32-e0a5-419e-ba5c-67863c975941"
}

variable "kubernetes_cluster_admin_username" {
  default = "k8sadmin"
}

// TODO read this from vault
variable "kubernetes_cluster_ssh_key" {}

variable "additional_node_pools" {
  default = {}
}

variable "control_resource_group" {
  default = ""
}

variable "enable_automatic_channel_upgrade_patch" {
  description = "When set to true automatic patch updates will be enabled on the cluster"
  default     = false
}

variable "enable_node_os_channel_upgrade_nodeimage" {
  default     = false
  description = "Feature toggle flag when set to true sets node_os_upgrade to NodeImage"
}

variable "upgrade_max_surge" {
  description = "Set the max surge when upgrading"
  default     = "33%"
}

variable "azure_policy_enabled" {
  description = "Enable the Azure Policy addon"
  default     = false
}

variable "node_os_maintenance_window_config" {
  type = object({
    frequency   = optional(string, "Weekly")
    interval    = optional(number, 1)
    duration    = optional(number, 4)
    day_of_week = optional(string, "Monday")
    start_time  = optional(string, "23:00")
    utc_offset  = optional(string, "+00:00")
    start_date  = optional(string, null)
    is_prod     = optional(bool, true)
  })
  default = {}

  validation {
    condition = var.node_os_maintenance_window_config.is_prod ? (tonumber(substr(var.node_os_maintenance_window_config.start_time, 0, 2)) >= 23
    ) || (tonumber(substr(var.node_os_maintenance_window_config.start_time, 0, 2)) <= 2) : true
    error_message = "Invalid 'start_time' Prod Use must only start between 23:00 - 02:00"
  }

  validation {
    condition     = var.node_os_maintenance_window_config.duration >= 4
    error_message = "Maintenance window duration must be at least 4 hours when node_os_channel_upgrade is enabled."
  }

  validation {
    condition     = try(contains(["Daily", "Weekly"], var.node_os_maintenance_window_config.frequency), false)
    error_message = "Maintenance window frequency must be set to 'Daily' or 'Weekly'."
  }

  validation {
    condition     = var.node_os_maintenance_window_config.interval >= 1
    error_message = "Maintenance window interval must be at least 1."
  }

  validation {
    condition     = var.node_os_maintenance_window_config.frequency == "Weekly" ? try(contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], var.node_os_maintenance_window_config.day_of_week), false) : true
    error_message = "Invalid 'day_of_week', please choose a day of the week."
  }
}
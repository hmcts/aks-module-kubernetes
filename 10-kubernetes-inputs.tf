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

variable "node_os_maintenance_window_duration" {
  description = "Duration of maintenance window"
  default = 4
}

variable "node_os_maintenance_window_frequency" {
  description = "Frequency of maintenance window"  
  default = "Daily"
}

variable "node_os_maintenance_window_day_of_week" {
  description = "The day of the week for the maintenance run. Required in combination with weekly frequency. "
  default = "Monday"
}

variable "node_os_maintenance_window_interval" {
  description = "The interval for maintenance runs"  
  default = 1
}

variable "node_os_maintenance_window_start_time" {
  description = "Start time of maintenance run format HH:mm"  
  default = "01:00"
}

variable "node_os_maintenance_window_utc_offset" {
  description = "Used to adjust time zome of start time"  
  default = "+00:00"
}
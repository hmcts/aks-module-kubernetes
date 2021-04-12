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
  default = null
}
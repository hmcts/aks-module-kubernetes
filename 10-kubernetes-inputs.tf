variable "kubernetes_cluster_log_analytics_workspace_sku" {
  default = "Standard"
}

variable "kubernetes_cluster_log_analytics_solution_publisher" {
  default = "Microsoft"
}

variable "kubernetes_cluster_log_analytics_solution_product" {
  default = "OMSGallery/ContainerInsights"
}

variable "kubernetes_cluster_agent_count" {
  default = 3
}

variable "kubernetes_cluster_agent_vm_size" {
  default = "Standard_DS3_v2"
}

variable "kubernetes_cluster_agent_max_pods" {
  default = "50"
}

variable "kubernetes_cluster_agent_os_disk_size" {
  default = "30"
}

variable "kubernetes_cluster_agent_os_type" {
  default = "Linux"
}

variable "kubernetes_cluster_http_application_routing" {
  default = false
}

variable "kubernetes_cluster_version" {
  default = "1.14.8"
}

variable "kubernetes_cluster_network_plugin" {
  default = "azure"
}

variable "kubernetes_cluster_rbac_enabled" {
  default = "true"
}

variable "kubernetes_cluster_role_binding_groups" {
  type = "map"

  default = {}
}

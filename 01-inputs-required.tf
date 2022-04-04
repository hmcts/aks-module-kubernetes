variable "control_vault" {}

variable "environment" {}
variable "network_name" {}
variable "network_shortname" {}
variable "network_resource_group_name" {}

variable "cluster_number" {}
variable "service_shortname" {}
variable "project" {}


variable "resource_group_name" {}
variable "location" {}

# Tags
variable "tags" {}

variable "log_workspace_id" {
  description = "Enter Log Analytics Workspace id"
}

variable "project_acr_enabled" {
  default = true
}

variable "global_acr_enabled" {
  default = true
}

variable "monitor_diagnostic_setting" {
  default = true
}

variable "sku_tier" {
  default     = "Free"
  description = "Free or Paid (which includes the uptime SLA)"
}

variable "ptl_cluster" {
  default = false
}

variable "enable_user_system_nodepool_split" {
  default = false
}
variable "availability_zones" {
  type    = list(any)
  default = []
}

variable "kubelet_uami_enabled" {
  default = false
  description = "Feature toggle flag to enable/disable the use our own managed identity"
}
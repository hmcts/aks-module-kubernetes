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
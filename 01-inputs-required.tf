variable "hmcts_access_vault" {}

variable "deploy_environment" {}
variable "network_name" {}
variable "network_shortname" {}
variable "network_resource_group_name" {}

variable "service_shortname" {}
variable "service_name_prefix" {}


variable "resource_group_name" {}
variable "location" {}

variable "kubernetes_cluster_admin_username" {}
variable "kubernetes_cluster_ssh_key" {}
variable "kubernetes_cluster_client_id" {}
variable "kubernetes_cluster_client_secret" {}

# Tags
variable "tag_project_name" {}

variable "tag_service" {}
variable "tag_environment" {}
variable "tag_cost_center" {}
variable "tag_app_operations_owner" {}
variable "tag_system_owner" {}
variable "tag_budget_owner" {}

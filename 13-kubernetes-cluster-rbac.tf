#--------------------------------------------------------------
# Kubernetes Cluster RBAC
#--------------------------------------------------------------

provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.cluster_ca_certificate)}"
}

## create cluster role bindings from a map, whose values are colon seperated strings
## this list defaults to {}
## each cluster_role_binding_groups map key/value pair should have the format:
## <group_name>: "<group_subject_kind>:<group_subject_api_group>:<group_subject_name>:
## eg:  variable "cluster_role_binding_groups" {
##          type = "map"
##          default = {
##              devops = "Group:rbac.authorization.k8s.io:894656e1-39f8-4bfe-b16a-510f61af6f41"
##              developers = "Group:rbac.authorization.k8s.io:894656e1-39f8-4bfe-b16a-510f61af6f41"
##          }
##      }
## group_subject_kind should always be "Group"
## group_subject_api_group should always be "rbac.authorization.k8s.io"

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  count = "${(var.kubernetes_cluster_rbac_enabled == "true" ? 1 : 0) * length(var.kubernetes_cluster_role_binding_groups)}"

  metadata {
    name = "${replace(
        format("%s_%s_cluster_admin",
            var.service_name_prefix,
            element(
                keys(var.kubernetes_cluster_role_binding_groups),
                count.index
            )
        ),
        "_",
        "-"
    )}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind = "${element(
        split(":",
            element(
                values(var.kubernetes_cluster_role_binding_groups),
                count.index
            )
        ),
        0
    )}"

    api_group = "${element(
        split(":",
            element(
                values(var.kubernetes_cluster_role_binding_groups),
                count.index
            )
        ),
        1
    )}"

    name = "${element(
        split(":",
            element(
                values(var.kubernetes_cluster_role_binding_groups),
                count.index
            )
        ),
        2
    )}"
  }
}

##########################
# Namespace resources
##########################

resource "kubernetes_namespace" "this" {
  for_each = toset(var.namespaces)
  metadata { name = each.value }
  lifecycle {
    ignore_changes = [metadata[0].labels]
    prevent_destroy = false
  }
  timeouts {
    delete = "45m"
  }
}

##########################
# Admin Role (namespace-admin) - dynamic rules per namespace
##########################

resource "kubernetes_role" "admin" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "namespace-admin"
    namespace = each.value
  }

  dynamic "rule" {
    for_each = lookup(var.admin_role_rules, each.value, [])
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

##########################
# Admin RoleBinding (bind multiple subjects)
##########################

resource "kubernetes_role_binding" "admin_binding" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "${each.value}-admin-binding"
    namespace = each.value
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.admin[each.value].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = lookup(local.namespace_admin_groups, each.value, "")
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "cluster_admins" {
  for_each = toset(var.cluster_admin_role_sp_object_ids)

  metadata {
    name = "cluster-admin-binding-${each.value}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = each.value
    api_group = "rbac.authorization.k8s.io"
  }
}

##########################
# App Role (non-admin) - dynamic rules per namespace
##########################

resource "kubernetes_role" "app" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "${each.value}-role"
    namespace = each.value
  }

  dynamic "rule" {
    for_each = lookup(var.app_role_rules, each.value, [])
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

##########################
# App Role Binding (bind single group per namespace)
##########################

resource "kubernetes_role_binding" "app_binding" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "${each.value}-rolebinding"
    namespace = each.value
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.app[each.value].metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "Group"
    name      = lookup(local.namespace_app_group, each.value, "")
    api_group = "rbac.authorization.k8s.io"
  }
}

##########################
# Workload Identity Service Accounts per namespace
##########################

resource "kubernetes_service_account" "oidc_sa" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "${each.value}-sa" # unique per namespace
    namespace = each.value
    annotations = {
      "azure.workload.identity/client-id" = var.workload_identity_client_id
    }
  }
}

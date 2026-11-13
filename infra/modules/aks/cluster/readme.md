# AKS Cluster Module

This Terraform module provisions an Azure Kubernetes Service (azurerm_kubernetes_cluster) with a default system node pool, optional addons (Container Insights, Prometheus, AGIC, Key Vault Secrets Provider), and common configuration for networking, identity and CSI drivers.

## Usage

```hcl
module "aks" {
  source              = "./modules/aks/cluster"

  # Required
  resource_group_name = "rg-aks"           # required
  location            = "eastus"          # required (Azure requires a location)
  subnet_id           = data.azurerm_subnet.aks_subnet.id # required

  # Optional examples
  cluster_name                 = "aks-poc"
  system_node_vm_size          = "Standard_D4s_v3"
  system_node_count            = 3
  enable_container_insights    = true
  log_analytics_workspace_id   = module.la_workspace.la_workspace_id  # required if container insights enabled
  enable_private_cluster       = false
}
```

## Variables

Only variables defined in variables.tf are listed below. Variables that Azure requires (resource group, location, vnet/subnet) are marked as Required. Conditional requirements are noted.

| Name                             | Type         | Description                                                                                         | Required                | Default        |
|----------------------------------|--------------|-----------------------------------------------------------------------------------------------------|-------------------------|----------------|
| resource_group_name              | string       | Name of the existing resource group where AKS and other resources are deployed.                    | Yes (Azure required)    | n/a            |
| location                         | string       | Azure region for the AKS cluster.                                                                   | Yes (Azure required)    | "eastus"      |
| subnet_id                        | string       | Id of the existing subnet in the VNet for AKS node pools (vnet_subnet_id).                         | Yes (resource usage)    | n/a            |
| acr_name                         | string       | Name of the existing Azure Container Registry (ACR) for pulling images.                            | No                      | "acrpoc"       |
| cluster_name                     | string       | Name of the AKS cluster.                                                                            | No                      | "aks-poc"      |
| use_user_assigned_identity       | bool         | Use a user-assigned identity for the AKS cluster.                                                   | No                      | false          |
| cluster_user_assigned_identity   | string       | User assigned identity of the AKS cluster (required if use_user_assigned_identity = true).          | Conditionally required  | n/a            |
| dns_prefix                       | string       | DNS prefix used by the AKS cluster for API server access.                                           | No                      | "aks-poc"      |
| load_balancer_sku                | string       | Load balancer SKU for AKS load balancer service.                                                     | No                      | "basic"        |
| kubernetes_version               | string/null  | Kubernetes version for the AKS cluster (null = latest supported).                                   | No                      | null           |
| system_node_vm_size              | string       | VM size for the AKS system node pool.                                                                | No                      | "Standard_D4s_v3" |
| system_node_count                | number       | Number of nodes in the AKS system node pool.                                                         | No                      | 3              |
| auto_scaling_enabled             | bool         | Enable autoscaling for the system node pool.                                                         | No                      | false          |
| min_node_count                   | number       | Minimum nodes for autoscaling.                                                                       | No                      | 1              |
| max_node_count                   | number       | Maximum nodes for autoscaling.                                                                       | No                      | 3              |
| enable_container_insights        | bool         | Enable Container Insights add-on.                                                                    | No                      | false          |
| log_analytics_workspace_id       | string       | Resource ID of the Log Analytics Workspace (required if enable_container_insights = true).          | Conditionally required  | n/a            |
| enable_prometheus_monitoring     | bool         | Enable Prometheus monitoring add-on.                                                                 | No                      | false          |
| monitor_allowed_annotations      | string       | Comma-separated k8s annotations to include as metric labels.                                         | No                      | default value  |
| monitor_allowed_labels           | string       | Comma-separated k8s labels to include as metric labels.                                              | No                      | default value  |
| enable_agic                      | bool         | Enable App Gateway Ingress Controller add-on.                                                        | No                      | false          |
| application_gateway_id           | string       | Application Gateway resource ID (required if enable_agic = true).                                    | Conditionally required  | n/a            |
| enable_aks_kv_secrets_provider   | bool         | Enable AKS Key Vault Secrets Provider add-on.                                                        | No                      | false          |
| enable_rbac                      | bool         | Enable RBAC for AKS.                                                                                 | No                      | true           |
| enable_oidc                      | bool         | Enable OIDC/workload identity.                                                                       | No                      | false          |
| enable_blob_csi_driver           | bool         | Enable Blob CSI Driver for AKS.                                                                      | No                      | true           |
| enable_disk_csi_driver           | bool         | Enable Disk CSI Driver for AKS.                                                                      | No                      | true           |
| enable_file_csi_driver           | bool         | Enable File CSI Driver for AKS.                                                                      | No                      | true           |
| aks_admin_group_object_id        | string       | Object ID of the Azure AD group that will have admin access to the AKS cluster.                     | No                      | n/a            |
| iac_sp_object_id                 | string       | Object ID of the Service Principal used by IaC tools.                                                | No                      | "poc-iac-terraform" |
| github_action_sp_object_id       | string       | Object ID of the Service Principal used by GitHub Actions.                                           | No                      | "github-actions-poc" |
| enable_private_cluster           | bool         | Enable private cluster for AKS.                                                                       | No                      | false          |
| private_dns_zone_id              | string       | ID of the private DNS zone for the AKS private cluster (required if enable_private_cluster = true).  | Conditionally required  | n/a            |

## Outputs

| Name                      | Description |
|---------------------------|-------------|
| aks_cluster_id            | azurerm_kubernetes_cluster.aks.id |
| aks_cluster_name          | azurerm_kubernetes_cluster.aks.name |
| kube_admin_config         | kube_admin_config (sensitive) — admin kubeconfig for the cluster |
| kube_config               | kube_config (sensitive) — user kubeconfig for the cluster |
| aks_kubelet_principal_id  | kubelet managed identity principal/object ID |
| aks_principal_id          | Cluster principal identity ID |
| aks_node_resource_group   | Resource group name for AKS nodes (node resource group) |
| aks_kubelet_uami_client_id| Client ID of the kubelet user-assigned identity (if used) |
| aks_resource_group        | Resource group name where the AKS cluster lives |

## Recommendations

- Always provide explicit resource_group_name, location and subnet_id values (Azure requires these for resource creation).
- Use managed identities and least-privilege RBAC; set use_user_assigned_identity and supply cluster_user_assigned_identity when needed.
- Enable Container Insights (and provide log_analytics_workspace_id) for production monitoring, or integrate with your centralized monitoring workspace.
- For private clusters, provide private_dns_zone_id and plan DNS/private endpoint routing for any consumers of the API server or metrics.
- Test node sizes, autoscaling policies and addons in a lower environment before production.
- Keep kubeconfigs and admin credentials secure — treat outputs marked sensitive appropriately in CI/CD pipelines.

## References

- Terraform azurerm_kubernetes_cluster: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster  
- Azure AKS overview & concepts: https://learn.microsoft.com/azure/aks/overview  
- AKS best practices for production: https://learn.microsoft.com/azure/aks/best-practices

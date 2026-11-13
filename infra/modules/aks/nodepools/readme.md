# AKS Node Pool Module

This Terraform module creates an additional AKS user node pool (azurerm_kubernetes_cluster_node_pool) and configures scaling, availability zones, taints, GPU driver installation and subnet placement.

## Usage

```hcl
module "nodepool" {
  source = "./modules/aks/nodepools"

  # Required
  node_pool_name   = "userpool1"
  aks_cluster_id   = data.azurerm_kubernetes_cluster.aks.id
  node_vm_size     = "Standard_D2s_v3"
  subnet_id        = data.azurerm_subnet.app.id

  # Optional
  node_count                 = 1
  node_auto_scaling_enabled  = false
  node_min_count             = 1
  node_max_count             = 3
  node_availability_zones    = ["1","2","3"]
  node_taints                = []
  gpu_node                   = false
}
```

## Variables

Only variables defined in this module's variables.tf are listed below. Variables required by the azurerm_kubernetes_cluster_node_pool resource are marked "Yes".

| Name                    | Type         | Description                                                           | Required | Default       |
|-------------------------|--------------|-----------------------------------------------------------------------|----------|---------------|
| node_pool_name          | string       | Name of the AKS node pool                                             | Yes      | n/a           |
| aks_cluster_id          | string       | Resource ID of the AKS cluster to attach the node pool to            | Yes      | n/a           |
| node_vm_size            | string       | VM size for nodes (e.g., Standard_D2s_v3)                             | Yes      | n/a           |
| node_count              | number       | Initial node count for the node pool                                  | No       | 1             |
| node_min_count          | number       | Minimum node count for autoscaling                                    | No       | 1             |
| node_max_count          | number       | Maximum node count for autoscaling                                    | No       | 3             |
| node_auto_scaling_enabled | bool       | Enable autoscaling for the node pool                                  | No       | false         |
| node_availability_zones | list(string) | Availability zones for the node pool                                  | No       | ["1","2","3"] |
| node_taints             | list(string) | Node taints for the node pool (e.g., ["sku=gpu:NoSchedule"])         | No       | []            |
| subnet_id               | string       | ID of the existing subnet in the VNet for AKS node pools               | Yes      | n/a           |
| gpu_node                | bool         | Indicates if the node pool is for GPU workloads (installs drivers)     | No       | false         |

Notes:
- azurerm_kubernetes_cluster_node_pool requires a cluster ID, a node pool name, a VM size and the subnet ID (vnet_subnet_id) to create the pool.
- When node_auto_scaling_enabled = true, node_count is ignored and min_count/max_count are used.

## Outputs

| Name             | Description |
|------------------|-------------|
| user_nodepool_id | ID of the created AKS node pool (azurerm_kubernetes_cluster_node_pool.user_node_pool.id) |

## Recommendations

- Use autoscaling for variable workloads; set sensible min/max limits to control cost.
- Pin node_vm_size to supported SKUs for your region and GPU drivers if using GPU nodes.
- Place node pools in appropriate subnets with sufficient IP capacity and network security rules.
- Use taints/labels to isolate workloads (GPU, spot, critical).
- Test upgrades and surge settings in a staging environment before production usage.

## References

- Terraform azurerm_kubernetes_cluster_node_pool: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool  
- Azure AKS node pools overview: https://learn.microsoft.com/azure/aks/concepts-node-pools  
- Azure VM sizes: https://learn.microsoft.com/azure/virtual-machines/sizes
# Data Collection Rule (DCR) Module

This module provisions an Azure Monitor Data Collection Endpoint (DCE), a Data Collection Rule (DCR) configured to forward Prometheus metrics to Azure Monitor metrics, and associates the DCR with an existing AKS cluster so telemetry from that cluster is routed to Azure Monitor.

Resources created
- azurerm_monitor_data_collection_endpoint (name: <aks_cluster_name>-dce)  
- azurerm_monitor_data_collection_rule (name: <aks_cluster_name>-dcr)  
  - kind = "Linux"  
  - data_sources → prometheus_forwarder (streams: ["Microsoft-PrometheusMetrics"])  
  - destinations → azure_monitor_metrics  
  - data_flow routes Prometheus metrics to Azure Monitor metrics  
- azurerm_monitor_data_collection_rule_association — attaches the DCR to the target AKS cluster

---

### Example usage

```hcl
module "dcr" {
  source              = "./modules/monitoring/datacollectionrules"

  # Required
  aks_cluster_name     = "aks-poc"
  resource_group_name  = "rg-tf-poc"

  # Optional (default shown)
  # location           = "eastus"
}
```

---

### Variables

| Name                 | Type    | Description                                                            | Required | Default   |
|----------------------|---------|------------------------------------------------------------------------|----------|-----------|
| aks_cluster_name     | string  | Name of the existing AKS cluster to associate the DCR with            | Yes      | n/a       |
| resource_group_name  | string  | Name of the resource group where resources are created / AKS exists   | Yes      | n/a       |
| location             | string  | Azure region for the Data Collection Endpoint and DCR                 | No       | "eastus" |
| azmonitor_workspace_id | string  | The ID of the Azure Monitor Workspace to send data to                 | Yes      | n/a |

---

### Outputs

| Name  | Description |
|-------|-------------|
| dce_id | ID of the created Data Collection Endpoint (azurerm_monitor_data_collection_endpoint.dce.id) |
| dcr_id | ID of the created Data Collection Rule (azurerm_monitor_data_collection_rule.prometheus_dcr.id) |

---

### Raw variable blocks

```hcl
variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "aks_cluster_name" {
  type        = string
  description = "Name of the AKS cluster."
}

variable "azmonitor_workspace_id" {
  type        = string
  description = "The ID of the Azure Monitor Workspace to send data to."  
}
```

### Raw outputs

```hcl
output "dce_id" {
  value = azurerm_monitor_data_collection_endpoint.dce.id
}

output "dcr_id" {
  value = azurerm_monitor_data_collection_rule.prometheus_dcr.id
}
```

---

### Notes & requirements
- The AKS cluster must exist. The module reads the cluster via data.azurerm_kubernetes_cluster and associates the DCR with that cluster.
- The executing identity running Terraform must have permissions to create monitoring resources and to associate the DCR with the AKS cluster in the specified resource group.
- Adjust main.tf if you need additional data sources, destinations, or different DCR configuration.

### References
- Azure Monitor Data Collection Rules overview: https://learn.microsoft.com/azure/azure-monitor/essentials/data-collection-rule-overview  
- Data Collection Endpoint / Rule docs: https://learn.microsoft.com/azure/azure-monitor/agents/data-collection-endpoint  
- DCR association: https://learn.microsoft.com/azure/azure-monitor/agents/data-collection-rule-associate

See module implementation:
- modules/monitoring/datacollectionrules/main.tf  
- modules/monitoring/datacollectionrules/variables.tf  
- modules/monitoring/datacollectionrules/outputs.tf
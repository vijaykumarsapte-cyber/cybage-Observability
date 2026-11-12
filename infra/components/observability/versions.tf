terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.37.0"
    }
  }

  # Existing remote state backend. The pipeline passes the same values via
  # -backend-config, these are kept identical so local init targets the same state.
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-observability"
    storage_account_name = "stobsstatedev1"
    container_name       = "tfstate"
    key                  = "observability-platform.dev.tfstate"
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
}

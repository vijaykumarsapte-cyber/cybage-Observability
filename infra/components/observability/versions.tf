terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.37.0"
    }
  }

  # Remote state (created by hand once - build step 1). The pipeline passes the
  # same values to init; they are kept identical so a local init uses the same state.
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-observability"
    storage_account_name = "stobsstatedev1"
    container_name       = "tfstate"
    key                  = "observability-platform.dev.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      # Soft delete (7 days) keeps a deleted vault's name reserved. Recover it
      # instead of failing with "vault already exists in soft-deleted state".
      recover_soft_deleted_key_vaults = true
      purge_soft_delete_on_destroy    = false
    }
  }
  storage_use_azuread = true
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
}

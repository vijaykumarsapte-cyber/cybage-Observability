terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.37.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rsg-observability-state-dev"
    storage_account_name = "stobsstatedev"
    container_name        = "tfstate"
    key                   = "observability-platform.dev.tfstate"
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id = var.subscription_id
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.87.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0.4"
    }
  }
}

provider "azurerm" {
  features {}
  
}

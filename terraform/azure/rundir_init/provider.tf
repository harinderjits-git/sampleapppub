terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    mssql = {
      source = "betr-io/mssql"
      version = "0.2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }

  }
}

provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = ">=1.6.0"
    }
  }
  required_version = ">= 1.0.1"
}
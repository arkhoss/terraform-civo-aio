terraform {
  required_providers {
    civo = {
      source  = "civo/civo"
      version = ">= 1.1.7"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.6.4"
    }
  }
}

provider "civo" {
  region = var.region
}


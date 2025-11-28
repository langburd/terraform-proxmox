terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.87.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.endpoint
  insecure = true
  password = var.password
  username = var.username

  ssh {
    agent = true
  }
}

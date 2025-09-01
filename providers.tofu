terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
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

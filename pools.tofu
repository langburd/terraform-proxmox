resource "proxmox_virtual_environment_pool" "production" {
  comment = "Managed by Terraform"
  pool_id = "production"
}

resource "proxmox_virtual_environment_pool" "development" {
  comment = "Managed by Terraform"
  pool_id = "development"
}

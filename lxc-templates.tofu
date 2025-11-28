resource "proxmox_virtual_environment_download_file" "lxc_img" {
  for_each = local.lxc_templates

  content_type = "vztmpl"
  datastore_id = "lenovo16-hdd"
  node_name    = "macmini8"
  url          = each.value
}


locals {
  lxc_templates = {
    "alpine"   = "http://download.proxmox.com/images/system/alpine-3.22-default_20250617_amd64.tar.xz"
    "debian12" = "http://download.proxmox.com/images/system/debian-12-standard_12.12-1_amd64.tar.zst"
    "debian13" = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst"
    "ubuntu22" = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    "ubuntu24" = "http://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  }
}

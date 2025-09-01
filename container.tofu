resource "proxmox_virtual_environment_container" "debian_container" {
  description = "Managed by Terraform"

  node_name = "macmini8"

  initialization {
    hostname = "debian12"

    dns {
      servers = ["192.168.8.1"]
    }

    ip_config {
      ipv4 {
        address = "192.168.9.21/23"
        gateway = "192.168.8.1"
      }
    }

    user_account {
      keys = [
        trimspace(file("~/.ssh/langburd.pub"))
      ]
      password = "zxasqw12"
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "lenovo16-ssd"
    size         = 4
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "lenovo16-hdd:vztmpl/ubuntu-24.10-standard_24.10-1_amd64.tar.zst"
    # type = "ubuntu"
    type = "debian"
  }

  # startup {
  #   order      = "3"
  #   up_delay   = "60"
  #   down_delay = "60"
  # }

  tags = ["test", "debian"]
}

resource "proxmox_virtual_environment_download_file" "lxc_img" {
  content_type = "vztmpl"
  datastore_id = "lenovo16-hdd"
  node_name    = "macmini8"
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
  # url          = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

resource "null_resource" "container_setup" {
  depends_on = [proxmox_virtual_environment_container.debian_container]

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "remote-exec" {
    connection {
      host        = "192.168.9.21"
      host_key    = null
      private_key = file("~/.ssh/langburd")
      type        = "ssh"
      user        = "root"
    }

    inline = [
      "apt update",
      "apt install -y dnsutils htop net-tools",
    ]
  }
}

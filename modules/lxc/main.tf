resource "proxmox_virtual_environment_container" "container" {
  # Core configuration
  node_name    = var.node_name
  vm_id        = var.vm_id
  description  = var.description
  tags         = var.tags
  template     = var.template
  unprivileged = var.unprivileged
  protection   = var.protection
  started      = var.started

  # Operating system configuration (only if not cloning)
  dynamic "operating_system" {
    for_each = var.operating_system != null ? [var.operating_system] : []
    content {
      template_file_id = operating_system.value.template_file_id
      type             = operating_system.value.type
    }
  }

  # CPU configuration
  cpu {
    architecture = var.cpu.architecture
    cores        = var.cpu.cores
    units        = var.cpu.units
  }

  # Memory configuration
  memory {
    dedicated = var.memory.dedicated
    swap      = var.memory.swap
  }

  # Disk configuration (only if not cloning)
  dynamic "disk" {
    for_each = var.disk != null ? [var.disk] : []
    content {
      datastore_id = disk.value.datastore_id
      size         = disk.value.size
    }
  }

  # Primary network interface
  network_interface {
    name        = var.network_interface.name
    bridge      = var.network_interface.bridge
    enabled     = var.network_interface.enabled
    firewall    = var.network_interface.firewall
    mac_address = var.network_interface.mac_address
    mtu         = var.network_interface.mtu
    rate_limit  = var.network_interface.rate_limit
    vlan_id     = var.network_interface.vlan_id
  }

  # Additional network interfaces
  dynamic "network_interface" {
    for_each = var.additional_network_interfaces
    content {
      name        = network_interface.value.name
      bridge      = network_interface.value.bridge
      enabled     = network_interface.value.enabled
      firewall    = network_interface.value.firewall
      mac_address = network_interface.value.mac_address
      mtu         = network_interface.value.mtu
      rate_limit  = network_interface.value.rate_limit
      vlan_id     = network_interface.value.vlan_id
    }
  }

  # Initialization configuration
  # Only create initialization block if:
  # 1. var.initialization is not null AND
  # 2. At least one meaningful field is set (hostname, dns, ip_config, or user_account)
  # This prevents issues with cloned containers where Proxmox API rejects empty/null hostnames
  dynamic "initialization" {
    for_each = (
      var.initialization != null &&
      (
        try(var.initialization.hostname, null) != null ||
        try(var.initialization.dns, null) != null ||
        try(var.initialization.ip_config, null) != null ||
        try(var.initialization.user_account, null) != null
      )
    ) ? [var.initialization] : []
    content {
      hostname = initialization.value.hostname

      dynamic "dns" {
        for_each = initialization.value.dns != null ? [initialization.value.dns] : []
        content {
          domain  = dns.value.domain
          servers = dns.value.servers
        }
      }

      dynamic "ip_config" {
        for_each = initialization.value.ip_config != null ? [initialization.value.ip_config] : []
        content {
          dynamic "ipv4" {
            for_each = ip_config.value.ipv4 != null ? [ip_config.value.ipv4] : []
            content {
              address = ipv4.value.address
              gateway = ipv4.value.gateway
            }
          }

          dynamic "ipv6" {
            for_each = ip_config.value.ipv6 != null ? [ip_config.value.ipv6] : []
            content {
              address = ipv6.value.address
              gateway = ipv6.value.gateway
            }
          }
        }
      }

      user_account {
        keys     = distinct(concat(try(initialization.value.user_account.keys, []), [var.ssh_key]))
        password = try(initialization.value.user_account.password, var.app_password)
      }
    }
  }

  # Mount points
  dynamic "mount_point" {
    for_each = var.mount_point
    content {
      volume    = mount_point.value.volume
      path      = mount_point.value.path
      backup    = mount_point.value.backup
      quota     = mount_point.value.quota
      read_only = mount_point.value.read_only
      replicate = mount_point.value.replicate
      shared    = mount_point.value.shared
      size      = mount_point.value.size
    }
  }

  # Console configuration
  console {
    enabled   = var.console.enabled
    tty_count = var.console.tty
    type      = var.console.type
  }

  # Features configuration
  dynamic "features" {
    for_each = var.features != null ? [var.features] : []
    content {
      fuse    = features.value.fuse
      keyctl  = features.value.keyctl
      mount   = features.value.mount
      nesting = features.value.nesting
    }
  }

  # Optional configurations
  hook_script_file_id = var.hook_script_file_id
  # Note: pool_id is deprecated on container resource, use proxmox_virtual_environment_pool_membership instead

  # Startup configuration
  dynamic "startup" {
    for_each = var.startup != null ? [var.startup] : []
    content {
      order      = startup.value.order
      up_delay   = startup.value.up_delay
      down_delay = startup.value.down_delay
    }
  }

  # Clone configuration
  dynamic "clone" {
    for_each = var.clone != null ? [var.clone] : []
    content {
      vm_id        = clone.value.vm_id
      datastore_id = clone.value.datastore_id
      node_name    = clone.value.node_name
    }
  }

  # Lifecycle block to prevent drift on attributes that may be modified externally
  # - started: May be changed by Docker AppArmor workaround script
  # - description: May include comments added to LXC config by external scripts
  lifecycle {
    ignore_changes = [started, description]
  }
}

# Pool membership resource (replaces deprecated pool_id attribute on container)
# Only created when pool_id is specified
resource "proxmox_virtual_environment_pool_membership" "container_pool" {
  count = var.pool_id != null ? 1 : 0

  pool_id = var.pool_id
  vm_id   = proxmox_virtual_environment_container.container.vm_id
}

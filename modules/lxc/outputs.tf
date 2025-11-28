output "container_id" {
  description = "The unique identifier of the container"
  value       = try(proxmox_virtual_environment_container.container.id, null)
}

output "cpu_cores" {
  description = "The number of CPU cores allocated to the container"
  value       = try(proxmox_virtual_environment_container.container.cpu[0].cores, null)
}

output "description" {
  description = "The description of the container"
  value       = try(proxmox_virtual_environment_container.container.description, null)
}

output "disk_datastore" {
  description = "The datastore where the container's disk is stored"
  value       = try(proxmox_virtual_environment_container.container.disk[0].datastore_id, null)
}

output "disk_size" {
  description = "The size of the container's disk (in GB)"
  value       = try(proxmox_virtual_environment_container.container.disk[0].size, null)
}

output "dns_domain" {
  description = "The DNS domain configured for the container"
  value       = try(proxmox_virtual_environment_container.container.initialization[0].dns[0].domain, null)
}

output "dns_servers" {
  description = "The DNS servers configured for the container"
  value       = try(proxmox_virtual_environment_container.container.initialization[0].dns[0].servers, null)
}

output "hostname" {
  description = "The hostname of the container"
  value       = try(proxmox_virtual_environment_container.container.initialization[0].hostname, null)
}

output "ipv4_address" {
  description = "The actual IPv4 address of the container (from DHCP or static configuration)"
  value       = try(proxmox_virtual_environment_container.container.ipv4, null)
}

output "ipv4_gateway" {
  description = "The IPv4 gateway of the container (from configuration)"
  value       = try(proxmox_virtual_environment_container.container.initialization[0].ip_config[0].ipv4[0].gateway, null)
}

output "ipv6_address" {
  description = "The actual IPv6 address of the container (from DHCP or static configuration)"
  value       = try(proxmox_virtual_environment_container.container.ipv6, null)
}

output "ipv6_gateway" {
  description = "The IPv6 gateway of the container (from configuration)"
  value       = try(proxmox_virtual_environment_container.container.initialization[0].ip_config[0].ipv6[0].gateway, null)
}

output "memory_dedicated" {
  description = "The amount of dedicated memory allocated to the container (in MB)"
  value       = try(proxmox_virtual_environment_container.container.memory[0].dedicated, null)
}

output "memory_swap" {
  description = "The amount of swap memory allocated to the container (in MB)"
  value       = try(proxmox_virtual_environment_container.container.memory[0].swap, null)
}

output "mount_points" {
  description = "The mount points configured for the container"
  value = [
    for mp in proxmox_virtual_environment_container.container.mount_point : {
      volume    = mp.volume
      path      = mp.path
      backup    = mp.backup
      quota     = mp.quota
      read_only = mp.read_only
      replicate = mp.replicate
      shared    = mp.shared
      size      = mp.size
    }
  ]
}

output "network_interfaces" {
  description = "The network interfaces configured for the container"
  value = [
    for ni in proxmox_virtual_environment_container.container.network_interface : {
      name        = ni.name
      bridge      = ni.bridge
      enabled     = ni.enabled
      firewall    = ni.firewall
      mac_address = ni.mac_address
      mtu         = ni.mtu
      rate_limit  = ni.rate_limit
      vlan_id     = ni.vlan_id
    }
  ]
}

output "node_name" {
  description = "The name of the Proxmox VE node where the container is running"
  value       = try(proxmox_virtual_environment_container.container.node_name, null)
}

output "operating_system" {
  description = "The operating system configuration of the container"
  value = length(proxmox_virtual_environment_container.container.operating_system) > 0 ? {
    template_file_id = proxmox_virtual_environment_container.container.operating_system[0].template_file_id
    type             = proxmox_virtual_environment_container.container.operating_system[0].type
  } : null
}

output "pool_id" {
  description = "The pool ID the container is assigned to"
  value       = var.pool_id
}

output "pool_membership_id" {
  description = "The pool membership resource ID (format: pool_id/type/vm_id)"
  value       = var.pool_id != null ? proxmox_virtual_environment_pool_membership.container_pool[0].id : null
}

output "protection" {
  description = "Whether the container is protected from deletion"
  value       = proxmox_virtual_environment_container.container.protection
}

output "started" {
  description = "Whether the container is started"
  value       = proxmox_virtual_environment_container.container.started
}

output "startup_down_delay" {
  description = "The startup down delay of the container"
  value       = try(proxmox_virtual_environment_container.container.startup[0].down_delay, null)
}

output "startup_order" {
  description = "The startup order of the container"
  value       = try(proxmox_virtual_environment_container.container.startup[0].order, null)
}

output "startup_up_delay" {
  description = "The startup up delay of the container"
  value       = try(proxmox_virtual_environment_container.container.startup[0].up_delay, null)
}

output "tags" {
  description = "The tags assigned to the container"
  value       = try(proxmox_virtual_environment_container.container.tags, null)
}

output "template" {
  description = "Whether the container is a template"
  value       = proxmox_virtual_environment_container.container.template
}

output "unprivileged" {
  description = "Whether the container runs as unprivileged"
  value       = proxmox_virtual_environment_container.container.unprivileged
}

output "vm_id" {
  description = "The VM ID of the container"
  value       = try(proxmox_virtual_environment_container.container.vm_id, null)
}

# Output container mount points
output "container_mount_points" {
  description = "Mount points for all containers"
  value = {
    for name, container in module.lxc_containers : name => {
      mount_points = container.mount_points
    }
  }
}

# Output container network information
output "container_networks" {
  description = "Network configuration for all containers"
  value = {
    for name, container in module.lxc_containers : name => {
      network_interfaces = container.network_interfaces
    }
  }
}

# Output container information
output "containers" {
  description = "Information about all created containers"
  value = {
    for name, container in module.lxc_containers : name => {
      container_id     = container.container_id
      vm_id            = container.vm_id
      node_name        = container.node_name
      hostname         = container.hostname
      ipv4_address     = container.ipv4_address
      ipv4_gateway     = container.ipv4_gateway
      ipv6_address     = container.ipv6_address
      ipv6_gateway     = container.ipv6_gateway
      dns_servers      = container.dns_servers
      dns_domain       = container.dns_domain
      tags             = container.tags
      description      = container.description
      cpu_cores        = container.cpu_cores
      memory_dedicated = container.memory_dedicated
      memory_swap      = container.memory_swap
      disk_size        = container.disk_size
      disk_datastore   = container.disk_datastore
      started          = container.started
      template         = container.template
      unprivileged     = container.unprivileged
      protection       = container.protection
    }
  }
}

# Output containers by tag for easy filtering
output "containers_by_tag" {
  description = "Containers grouped by their tags"
  value = {
    for tag in distinct(flatten([
      for name, container in module.lxc_containers : container.tags
      ])) : tag => [
      for name, container in module.lxc_containers : {
        name         = name
        container_id = container.container_id
        vm_id        = container.vm_id
        hostname     = container.hostname
        ipv4_address = container.ipv4_address
      } if contains(container.tags, tag)
    ]
  }
}

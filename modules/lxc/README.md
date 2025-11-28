# Proxmox LXC Container Module

This Terraform module provisions Proxmox LXC containers using the `proxmox_virtual_environment_container` resource from the `bpg/proxmox` provider.

## Features

- **Comprehensive Configuration**: Supports all available arguments from the Proxmox container resource
- **YAML-driven Configuration**: Uses `containers.yaml` as the single source of truth
- **Flexible Networking**: Supports multiple network interfaces with VLAN and firewall configuration
- **Storage Management**: Configurable disk and mount point management
- **Security Features**: Support for unprivileged containers, protection, and access control
- **Startup Control**: Configurable startup order and delays
- **Template Support**: Container cloning from templates
- **Resource Management**: CPU, memory, and timeout configuration

## Usage

### Basic Usage

1. Create a `containers.yaml` file in your root module:

```yaml
containers:
  web-server:
    node_name: "pve-node1"
    operating_system:
      template_file_id: "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      type: "debian"
    disk:
      datastore_id: "local-lvm"
      size: 8
    initialization:
      hostname: "web-server"
      ip_config:
        ipv4:
          address: "192.168.1.100/24"
          gateway: "192.168.1.1"
```

2. Call the module in your Terraform configuration:

```hcl
module "lxc_containers" {
  source = "./modules/lxc"

  for_each = local.containers

  node_name = each.value.node_name
  operating_system = each.value.operating_system
  disk = each.value.disk
  initialization = each.value.initialization
  # ... other configuration
}
```

### Advanced Configuration

The module supports advanced features like:

- Multiple network interfaces
- Custom mount points
- Container features (nesting, FUSE, etc.)
- Startup configuration
- Resource limits
- Security settings

See the example `containers.yaml` file for comprehensive configuration options.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| proxmox | >= 0.83.0 |

## Providers

| Name | Version |
|------|---------|
| proxmox | >= 0.83.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| node_name | The name of the Proxmox VE node where the container will be created | `string` | n/a | yes |
| operating_system | The operating system configuration | `object` | n/a | yes |
| disk | The disk configuration | `object` | n/a | yes |
| vm_id | The unique identifier of the container | `number` | `null` | no |
| description | The description of the container | `string` | `"Managed by Terraform"` | no |
| tags | A list of tags to assign to the container | `list(string)` | `[]` | no |
| cpu | The CPU configuration | `object` | `{cores=1, units=1024, architecture="amd64"}` | no |
| memory | The memory configuration | `object` | `{dedicated=512, swap=0}` | no |
| network_interface | Network interface configuration | `object` | `{name="veth0", bridge="vmbr0", enabled=true}` | no |
| initialization | Container initialization configuration | `object` | `{}` | no |
| started | Whether the container should be started after creation | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| container_id | The unique identifier of the container |
| vm_id | The VM ID of the container |
| node_name | The name of the Proxmox VE node where the container is running |
| hostname | The hostname of the container |
| ipv4_address | The IPv4 address of the container |
| ipv4_gateway | The IPv4 gateway of the container |
| tags | The tags assigned to the container |
| cpu_cores | The number of CPU cores allocated to the container |
| memory_dedicated | The amount of dedicated memory allocated to the container |
| disk_size | The size of the container's disk |
| network_interfaces | The network interfaces configured for the container |

## Examples

### Simple Web Server

```yaml
containers:
  nginx:
    node_name: "pve-node1"
    description: "Nginx web server"
    tags: ["web", "nginx"]
    operating_system:
      template_file_id: "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      type: "debian"
    disk:
      datastore_id: "local-lvm"
      size: 4
    initialization:
      hostname: "nginx"
      ip_config:
        ipv4:
          address: "192.168.1.10/24"
          gateway: "192.168.1.1"
```

### Database Server with Advanced Configuration

```yaml
containers:
  postgres:
    node_name: "pve-node1"
    vm_id: 200
    description: "PostgreSQL database server"
    tags: ["database", "postgres"]
    protection: true
    cpu:
      cores: 4
      units: 2048
    memory:
      dedicated: 4096
      swap: 1024
    operating_system:
      template_file_id: "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      type: "ubuntu"
    disk:
      datastore_id: "local-lvm"
      size: 20
    mount_point:
      - volume: "local-lvm:vm-200-disk-1"
        path: "/var/lib/postgresql"
        size: "50G"
        backup: true
    features:
      nesting: true
    startup:
      order: "1"
      up_delay: "30"
```

## License

This module is released under the MIT License. See LICENSE file for details.

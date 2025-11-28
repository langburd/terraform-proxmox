# Proxmox LXC Container Module

This module provisions Proxmox LXC containers using the `proxmox_virtual_environment_container` resource from the `bpg/proxmox` provider. It is written in standard HCL and is compatible with both Terraform and OpenTofu.

## Features

- Comprehensive configuration of a single LXC container (CPU, memory, disks, networking, initialization, features, startup, cloning).
- Designed to be driven by higher-level configuration (for example the YAML-driven root in this repository), but can also be used from any Terraform/OpenTofu root.
- Flexible networking: multiple network interfaces with VLAN and firewall configuration.
- Storage management: configurable disk and mount point management.
- Security features: unprivileged containers, protection, and access control.
- Startup control: configurable startup order and delays.
- Template and clone support for creating containers from templates.

## Usage

### Basic Usage

1. Call the module in your Terraform configuration:

```hcl
module "lxc_container" {
  source = "./modules/lxc" # or a remote source such as "github.com/langburd/terraform-proxmox//modules/lxc"

  node_name = "pve-node1"
  operating_system = {
    template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  }
  disk = {
    datastore_id = "local-lvm"
    size         = 8
  }
}
```

2. Initialize and apply with Terraform:

```bash
terraform init
terraform apply
```

When used from this repository's root configuration, the module is typically called in a `for_each` over containers loaded from `containers.yaml`. See the root `README.md` for details of that pattern.

### Advanced Configuration

The module supports advanced features like:

- Multiple network interfaces
- Custom mount points
- Container features (nesting, FUSE, etc.)
- Startup configuration
- Resource limits
- Security settings

See the example `containers.yaml` file for comprehensive configuration options.

## Examples

### Single container

```hcl
module "web" {
  source = "./modules/lxc"

  node_name = "pve-node1"

  operating_system = {
    template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  }

  initialization = {
    hostname = "web"
    ip_config = {
      ipv4 = {
        address = "192.168.1.101/24"
        gateway = "192.168.1.1"
      }
    }
  }
}
```

### Multiple containers with `for_each`

```hcl
locals {
  containers = {
    web = {
      node_name = "pve-node1"
      # ...
    }
    db = {
      node_name = "pve-node1"
      # ...
    }
  }
}

module "lxc" {
  source  = "./modules/lxc"
  for_each = local.containers

  node_name        = each.value.node_name
  operating_system = each.value.operating_system
  disk             = each.value.disk
  initialization   = each.value.initialization
}
```

## License

This module is released under the MIT License. See LICENSE file for details.

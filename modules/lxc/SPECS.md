# lxc

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.83.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >= 0.83.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_container.container](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_container) | resource |
| [proxmox_virtual_environment_pool_membership.container_pool](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_pool_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_network_interfaces"></a> [additional\_network\_interfaces](#input\_additional\_network\_interfaces) | Additional network interfaces | <pre>list(object({<br/>    name        = string<br/>    bridge      = optional(string, "vmbr0")<br/>    enabled     = optional(bool, true)<br/>    firewall    = optional(bool, false)<br/>    mac_address = optional(string)<br/>    mtu         = optional(number)<br/>    rate_limit  = optional(number)<br/>    vlan_id     = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_app_password"></a> [app\_password](#input\_app\_password) | The password for the root user of the LXC containers | `string` | `null` | no |
| <a name="input_clone"></a> [clone](#input\_clone) | Clone configuration for creating container from template | <pre>object({<br/>    vm_id        = number<br/>    datastore_id = optional(string)<br/>    node_name    = optional(string)<br/>    full         = optional(bool, true)<br/>  })</pre> | `null` | no |
| <a name="input_console"></a> [console](#input\_console) | Console configuration | <pre>object({<br/>    enabled = optional(bool, true)<br/>    tty     = optional(number, 2)<br/>    type    = optional(string, "console")<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "tty": 2,<br/>  "type": "console"<br/>}</pre> | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The CPU configuration | <pre>object({<br/>    architecture = optional(string, "amd64")<br/>    cores        = optional(number, 1)<br/>    units        = optional(number, 1024)<br/>  })</pre> | <pre>{<br/>  "architecture": "amd64",<br/>  "cores": 1,<br/>  "units": 1024<br/>}</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the container | `string` | `"Managed by Terraform"` | no |
| <a name="input_disk"></a> [disk](#input\_disk) | The disk configuration (null when cloning) | <pre>object({<br/>    datastore_id = string<br/>    size         = optional(number, 8)<br/>  })</pre> | `null` | no |
| <a name="input_features"></a> [features](#input\_features) | Container features configuration | <pre>object({<br/>    fuse    = optional(bool, false)<br/>    keyctl  = optional(bool, false)<br/>    mount   = optional(list(string), [])<br/>    nesting = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_hook_script_file_id"></a> [hook\_script\_file\_id](#input\_hook\_script\_file\_id) | The identifier for a file containing a hook script | `string` | `null` | no |
| <a name="input_initialization"></a> [initialization](#input\_initialization) | Container initialization configuration | <pre>object({<br/>    hostname = optional(string)<br/>    dns = optional(object({<br/>      domain  = optional(string)<br/>      servers = optional(list(string), [])<br/>    }))<br/>    ip_config = optional(object({<br/>      ipv4 = optional(object({<br/>        address = optional(string)<br/>        gateway = optional(string)<br/>      }))<br/>      ipv6 = optional(object({<br/>        address = optional(string)<br/>        gateway = optional(string)<br/>      }))<br/>    }))<br/>    user_account = optional(object({<br/>      keys     = optional(list(string), [])<br/>      password = optional(string)<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The memory configuration | <pre>object({<br/>    dedicated = optional(number, 512)<br/>    swap      = optional(number, 0)<br/>  })</pre> | <pre>{<br/>  "dedicated": 512,<br/>  "swap": 0<br/>}</pre> | no |
| <a name="input_mount_point"></a> [mount\_point](#input\_mount\_point) | Mount point configurations | <pre>list(object({<br/>    volume    = string<br/>    path      = string<br/>    backup    = optional(bool, false)<br/>    quota     = optional(bool, false)<br/>    read_only = optional(bool, false)<br/>    replicate = optional(bool, true)<br/>    shared    = optional(bool, false)<br/>    size      = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface configuration | <pre>object({<br/>    name        = optional(string, "veth0")<br/>    bridge      = optional(string, "vmbr0")<br/>    enabled     = optional(bool, true)<br/>    firewall    = optional(bool, false)<br/>    mac_address = optional(string)<br/>    mtu         = optional(number)<br/>    rate_limit  = optional(number)<br/>    vlan_id     = optional(number)<br/>  })</pre> | <pre>{<br/>  "bridge": "vmbr0",<br/>  "enabled": true,<br/>  "name": "veth0"<br/>}</pre> | no |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | The name of the Proxmox VE node where the container will be created | `string` | n/a | yes |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | The operating system configuration (null when cloning) | <pre>object({<br/>    template_file_id = string<br/>    type             = optional(string, "debian")<br/>  })</pre> | `null` | no |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | The identifier for a pool to assign the container to | `string` | `null` | no |
| <a name="input_protection"></a> [protection](#input\_protection) | Whether the container is protected from deletion | `bool` | `false` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The SSH public key for the root user of the LXC containers | `string` | `"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChfZryPRwPcle2fzNjZkjzDiTLOLBvDAx+Vj1zyMEMkoTGA7e8t0p6uuuQaL1ifunjlN7WvhTbvJYy4YNU1/YCN8g99SvZHpJxRDq0qti9W2DUeSdagw6+wSL0ZLseLbDpT4QMJzuGM8y/nkJVUcxTg08GGhDzLdjLxQRI37CTsrt3mShEnf0wp+SYC0hYjKXdYQo27VBNIIsa/MuuOfhgvg7lqM2vvQhCD/8MjHtwOZe8ae342JbK6bzyfBscLbXhxIw2+cIV8MFmvG4DeMCg71h1xfNR8ic9XW9OeW6nJZz4Fm1uysSZnrc24jsoNRl1taWPoCY/S3EvGzM+Hlxz avi@langburd.com"` | no |
| <a name="input_started"></a> [started](#input\_started) | Whether the container should be started after creation | `bool` | `true` | no |
| <a name="input_startup"></a> [startup](#input\_startup) | Startup and shutdown behavior configuration | <pre>object({<br/>    order      = optional(string)<br/>    up_delay   = optional(string)<br/>    down_delay = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A list of tags to assign to the container | `list(string)` | `[]` | no |
| <a name="input_template"></a> [template](#input\_template) | Whether this container is a template | `bool` | `false` | no |
| <a name="input_unprivileged"></a> [unprivileged](#input\_unprivileged) | Whether the container runs as unprivileged on the host | `bool` | `true` | no |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | The unique identifier of the container (if not specified, the next available ID will be used) | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The unique identifier of the container |
| <a name="output_cpu_cores"></a> [cpu\_cores](#output\_cpu\_cores) | The number of CPU cores allocated to the container |
| <a name="output_description"></a> [description](#output\_description) | The description of the container |
| <a name="output_disk_datastore"></a> [disk\_datastore](#output\_disk\_datastore) | The datastore where the container's disk is stored |
| <a name="output_disk_size"></a> [disk\_size](#output\_disk\_size) | The size of the container's disk (in GB) |
| <a name="output_dns_domain"></a> [dns\_domain](#output\_dns\_domain) | The DNS domain configured for the container |
| <a name="output_dns_servers"></a> [dns\_servers](#output\_dns\_servers) | The DNS servers configured for the container |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The hostname of the container |
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | The actual IPv4 address of the container (from DHCP or static configuration) |
| <a name="output_ipv4_gateway"></a> [ipv4\_gateway](#output\_ipv4\_gateway) | The IPv4 gateway of the container (from configuration) |
| <a name="output_ipv6_address"></a> [ipv6\_address](#output\_ipv6\_address) | The actual IPv6 address of the container (from DHCP or static configuration) |
| <a name="output_ipv6_gateway"></a> [ipv6\_gateway](#output\_ipv6\_gateway) | The IPv6 gateway of the container (from configuration) |
| <a name="output_memory_dedicated"></a> [memory\_dedicated](#output\_memory\_dedicated) | The amount of dedicated memory allocated to the container (in MB) |
| <a name="output_memory_swap"></a> [memory\_swap](#output\_memory\_swap) | The amount of swap memory allocated to the container (in MB) |
| <a name="output_mount_points"></a> [mount\_points](#output\_mount\_points) | The mount points configured for the container |
| <a name="output_network_interfaces"></a> [network\_interfaces](#output\_network\_interfaces) | The network interfaces configured for the container |
| <a name="output_node_name"></a> [node\_name](#output\_node\_name) | The name of the Proxmox VE node where the container is running |
| <a name="output_operating_system"></a> [operating\_system](#output\_operating\_system) | The operating system configuration of the container |
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | The pool ID the container is assigned to |
| <a name="output_pool_membership_id"></a> [pool\_membership\_id](#output\_pool\_membership\_id) | The pool membership resource ID (format: pool\_id/type/vm\_id) |
| <a name="output_protection"></a> [protection](#output\_protection) | Whether the container is protected from deletion |
| <a name="output_started"></a> [started](#output\_started) | Whether the container is started |
| <a name="output_startup_down_delay"></a> [startup\_down\_delay](#output\_startup\_down\_delay) | The startup down delay of the container |
| <a name="output_startup_order"></a> [startup\_order](#output\_startup\_order) | The startup order of the container |
| <a name="output_startup_up_delay"></a> [startup\_up\_delay](#output\_startup\_up\_delay) | The startup up delay of the container |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the container |
| <a name="output_template"></a> [template](#output\_template) | Whether the container is a template |
| <a name="output_unprivileged"></a> [unprivileged](#output\_unprivileged) | Whether the container runs as unprivileged |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | The VM ID of the container |
<!-- END_TF_DOCS -->

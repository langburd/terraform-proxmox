# terraform-proxmox

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.87.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.87.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lxc_containers"></a> [lxc\_containers](#module\_lxc\_containers) | ./modules/lxc | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.docker_apparmor_fix](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [proxmox_virtual_environment_download_file.lxc_img](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_file.alpine_docker_setup](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_pool.development](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_pool) | resource |
| [proxmox_virtual_environment_pool.production](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_password"></a> [app\_password](#input\_app\_password) | The password for the root user of the LXC containers | `string` | `null` | no |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | The Proxmox VE API endpoint. | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | The Proxmox VE password. Some operations not supported with API token. | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | The Proxmox VE username. Some operations not supported with API token. | `string` | `"root@pam"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_mount_points"></a> [container\_mount\_points](#output\_container\_mount\_points) | Mount points for all containers |
| <a name="output_container_networks"></a> [container\_networks](#output\_container\_networks) | Network configuration for all containers |
| <a name="output_containers"></a> [containers](#output\_containers) | Information about all created containers |
| <a name="output_containers_by_tag"></a> [containers\_by\_tag](#output\_containers\_by\_tag) | Containers grouped by their tags |
<!-- END_TF_DOCS -->

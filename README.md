# Proxmox LXC Containers with OpenTofu

This repository contains an opinionated OpenTofu root configuration and a reusable LXC module that works with both Terraform and OpenTofu. It lets you describe containers once in `containers.yaml`, then create, update, and destroy them in a repeatable way, including optional automation for Docker-in-LXC on Proxmox versions affected by the AppArmor issue (CVE-2025-52881).

The root configuration uses `.tofu` files and is intended to be executed with the `tofu` CLI only (not the `terraform` CLI). The `modules/lxc` submodule is written in standard HCL (`.tf`) and can be consumed from either Terraform or OpenTofu.

## Overview

- Root configuration (`*.tofu` files) that:
  - Parses `containers.yaml` into locals.
  - Invokes the `modules/lxc` Terraform module for each container.
  - Optionally downloads LXC OS templates and creates resource pools.
  - Manages Proxmox snippets and host-side scripts for Alpine Docker containers and the Docker AppArmor workaround.
- Reusable `modules/lxc` module that wraps `proxmox_virtual_environment_container` with strong validation and a YAML-friendly input structure.

For detailed variable, provider, and output documentation, refer to `SPECS.md` (generated Terraform docs) and `modules/lxc/README.md`.

## Main features

- YAML-driven configuration via a single `containers.yaml` file.
- Support for most `proxmox_virtual_environment_container` arguments, including:
  - CPU, memory, disks, mount points.
  - Initialization (hostname, networking, DNS, user account).
  - Network interfaces and additional interfaces.
  - Features, startup options, cloning, and timeouts.
- Separation of concerns:
  - Root module for orchestration, hooks, and infrastructure glue.
  - `modules/lxc` for the low-level container resource.
- Optional Proxmox automation:
  - Downloading standard LXC templates (`lxc-templates.tofu`).
  - Managing Proxmox pools (`pools.tofu`).
- Docker-on-LXC support for Proxmox < 9.1:
  - Host-side AppArmor fix applied via `null_resource.docker_apparmor_fix` and `scripts/docker-apparmor-fix.sh`.
  - Alpine Docker LXC hook script (`scripts/alpine-docker-setup.sh`) uploaded as a Proxmox snippet and referenced from containers.

## Project structure

```text
terraform-proxmox/
├── containers.yaml          # Declarative container definitions (single source of truth)
├── containers.tofu          # Root logic: parses YAML, calls modules/lxc, applies hooks
├── lxc-templates.tofu       # Optional download of LXC OS templates
├── pools.tofu               # Optional Proxmox resource pools
├── providers.tofu           # Terraform/OpenTofu and provider configuration
├── variables.tofu           # Root variables (endpoint, credentials, app_password, etc.)
├── outputs.tofu             # Root outputs
├── modules/
│   └── lxc/
│       ├── main.tf          # LXC container resource implementation
│       ├── variables.tf     # Module inputs and validation
│       ├── outputs.tf       # Module outputs
│       └── README.md        # Module-level documentation
├── scripts/
│   ├── alpine-docker-setup.sh   # LXC hookscript to provision Alpine Docker containers
│   └── docker-apparmor-fix.sh   # Host-side AppArmor workaround for Docker in LXC
├── hooks/
│   └── tfsort.sh            # Helper script to run tfsort on .tofu/.tf files
├── SPECS.md                 # Generated Terraform docs (providers, inputs, outputs, etc.)
└── README.md                # This file
```

## Prerequisites

- A Proxmox VE host or cluster reachable from where you run OpenTofu.
- OpenTofu CLI (`tofu`) installed; the root configuration uses `.tofu` files and is not intended to be run with the `terraform` CLI.
- Access credentials for the Proxmox API:
  - API endpoint (for example `https://your-proxmox-host:8006/api2/json`).
  - User with permission to manage LXC containers and snippets (for example `root@pam`).
- SSH access from the machine running OpenTofu to the Proxmox host, if you enable the Docker AppArmor workaround (`docker_apparmor_fix`), because it is implemented with an SSH-based `null_resource`.

Exact provider versions, inputs, and outputs are documented in `SPECS.md`.

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/<your-org>/terraform-proxmox.git
   cd terraform-proxmox
   ```

2. **Configure Proxmox credentials**

   Either export environment variables so OpenTofu can pick up the variables used in `providers.tofu`:

   ```bash
   export TF_VAR_endpoint="https://your-proxmox-host:8006/api2/json"
   export TF_VAR_username="root@pam"
   export TF_VAR_password="your-proxmox-host-root-password"
   export TF_VAR_app_password="container-root-password"
   ```

   or set the same variables in `terraform.tfvars`.

3. **Review providers and inputs**

   - Check `providers.tofu` and `variables.tofu` for how providers and root variables are defined.
   - See `SPECS.md` for the generated list of providers, inputs, and outputs when it has been refreshed with `terraform-docs` (or similar).

## Basic usage

1. **Describe containers in `containers.yaml`**

   Minimal example:

   ```yaml
   containers:
     web-server:
       node_name: "pve-node1"
       description: "Web server container"
       tags: ["web", "production"]
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
             address: "192.168.1.10/24"
             gateway: "192.168.1.1"
   ```

   See `modules/lxc/README.md` for the full set of supported fields and structures.

2. **Initialize and plan**

   ```bash
   tofu init
   tofu plan
   ```

3. **Apply**

   ```bash
   tofu apply
   ```

   This will:

   - Parse `containers.yaml`.
   - Create or update LXC containers via the `modules/lxc` module.
   - Upload the Alpine Docker hook script as a snippet.
   - Apply the Docker AppArmor workaround for any containers that have `docker_apparmor_fix` enabled in `containers.yaml`.

## Docker and hookscript integration (optional)

If you run Docker inside LXC containers on Proxmox versions affected by the AppArmor issue:

- Mark affected containers in `containers.yaml` with a `docker_apparmor_fix` flag.
- Configure their networking and `features` to allow nesting, as described in `modules/lxc/README.md`.
- Optionally configure a hook script (for example the Alpine Docker setup script) by setting `hook_script_file_id` in the container definition so it points at the snippet created by `proxmox_virtual_environment_file.alpine_docker_setup`.

The root configuration will:

- Upload `scripts/alpine-docker-setup.sh` as a Proxmox snippet.
- Run `scripts/docker-apparmor-fix.sh` on the Proxmox host via `null_resource.docker_apparmor_fix` before the first start of marked containers.

## Further documentation

- Module reference and configuration details (Terraform/OpenTofu module): `modules/lxc/README.md`.
- Generated provider/module documentation (providers, modules, inputs, outputs): `SPECS.md`.
- Script behaviour and advanced Docker/LXC handling: see comments inside `scripts/alpine-docker-setup.sh` and `scripts/docker-apparmor-fix.sh`.

---
name: new-container
description: Guide for adding a new LXC container to containers.yaml. Covers required fields, optional flags, defaults, clone vs fresh, and Docker setup.
disable-model-invocation: true
---

# Adding a New Container

All containers are defined in `containers.yaml`. The root config applies sane defaults — only specify values that differ from the defaults below.

## Defaults (from containers.tofu — no need to repeat these)

| Field | Default |
|-------|---------|
| OS | Alpine Linux (auto-downloaded) |
| CPU | 1 core, 1024 units |
| Memory | 512 MB dedicated, 0 swap |
| Disk | 8 GB on `lenovo16-ssd` |
| Pool | `production` |
| Network | `eth0` on bridge `vmbr0` |
| Started | `true` |
| Unprivileged | `false` |

## Minimal fresh container (no defaults overridden)

```yaml
containers:
  my-new-container:
    description: What this container does
    node_name: <proxmox-node>           # e.g., latitude16, hpelite32, macmini8
    initialization:
      hostname: my-new-container
      dns:
        servers:
          - 192.168.9.250
      ip_config:
        ipv4:
          address: 192.168.9.XXX/23    # Pick an unused static IP
          gateway: 192.168.9.250
    tags:
      - production
      - <service-type>
```

## Docker container (needs AppArmor fix for Proxmox < 9.1)

Add these fields on top of the minimal example:

```yaml
    docker_apparmor_fix: true
    hook_script_file_id: lenovo16-hdd:snippets/alpine-docker-setup.sh
```

- `docker_apparmor_fix: true` creates the container stopped, applies the AppArmor patch via SSH to the Proxmox host, then starts it.
- `hook_script_file_id` runs `alpine-docker-setup.sh` on the Proxmox host post-start to install Docker + Docker Compose inside the container.

## Clone from existing container

When cloning, **omit** `operating_system`, `disk`, and `initialization` (Proxmox API rejects them):

```yaml
    clone:
      vm_id: 100          # VMID of the source container
      node_name: <node>
```

## Mount point (bind-mount host directory)

```yaml
    mount_point:
      - path: /opt/my-app          # Path inside the container
        volume: /mnt/pve/lenovo16-ssd/data/my-app   # Path on Proxmox host
```

## Resource overrides (only when needed)

```yaml
    cpu:
      cores: 2
    memory:
      dedicated: 1024
      swap: 512
    disk:
      size: 20
      datastore_id: lenovo16-hdd
```

## Steps after editing containers.yaml

1. `yamlfmt .` — format YAML
2. `yamllint containers.yaml` — validate YAML syntax
3. `tofu validate` — validate HCL
4. `tofu plan` — review what will be created
5. `tofu apply` — create the container

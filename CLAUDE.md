# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Toolchain

- Always use the `tofu` CLI — never `terraform`. Root config uses `.tofu` file extensions which only execute with OpenTofu.
- Module code under `modules/lxc/` uses `.tf` (standard HCL, compatible with both tools).
- Run `pre-commit install` after cloning before making any commits.

## Commands

```bash
# Initialize
tofu init

# Plan / Apply
tofu plan
tofu apply

# Validate
tofu validate
tflint --recursive
checkov -d .

# Format (all three must be run after edits)
tofu fmt -recursive -diff   # HCL formatting
tfsort <file>               # Sort blocks within a file (run on changed .tofu/.tf files)
yamlfmt .                   # Format containers.yaml and other YAML files

# Regenerate module docs
terraform-docs .
```

## Architecture

`containers.yaml` is the single source of truth for all container definitions. The root config reads it with `yamldecode()`, then calls `modules/lxc` once per container via `for_each`.

**Defaults (from `containers.tofu`)** — only override what differs:
- OS: Alpine Linux
- CPU: 1 core, 1024 units
- Memory: 512 MB, 0 swap
- Disk: 8 GB on `lenovo16-ssd`
- Pool: `production`
- Network: `eth0` on bridge `vmbr0`

**Clone vs fresh container:** When using `clone:`, omit `operating_system`, `disk`, and `initialization` — the Proxmox API rejects them when cloning.

**Docker AppArmor fix** (`docker_apparmor_fix: true`): Workaround for Proxmox < 9.1. Container is created stopped, then `null_resource` SSHs to the Proxmox host to patch `/etc/pve/lxc/<VMID>.conf` before starting. Requires SSH access to `<node_name>.baza.ddyy.pro` as `root`.

## Git Workflow

- Branch naming: `kebab-case` feature branches (e.g., `add-pihole`, `fix-memory-defaults`)
- PRs target `master`; pre-commit hooks block direct commits to `master`
- Pre-commit enforces: `terraform fmt`, `tflint`, `tfsort`, `yamlfmt`, `yamllint`, `gitleaks`, file size limits

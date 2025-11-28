# Terraform Proxmox LXC Container Module

This repository provides a comprehensive Terraform module for managing Proxmox LXC containers using a YAML-driven configuration approach.

## 🚀 Features

- **YAML-Driven Configuration**: Single source of truth in `containers.yaml`
- **Comprehensive Support**: All `proxmox_virtual_environment_container` resource arguments
- **Flexible Deployment**: Support for both template-based and clone-based containers
- **Advanced Networking**: Multiple network interfaces, VLANs, firewall configuration
- **Storage Management**: Configurable disks and mount points
- **Security Features**: Unprivileged containers, protection, access control
- **Resource Management**: CPU, memory, and timeout configuration
- **Container Features**: Nesting, FUSE, custom capabilities
- **Startup Control**: Boot order and delay configuration

## 📁 Project Structure

```
terraform-proxmox/
├── modules/lxc/              # LXC container module
│   ├── main.tf              # Container resource implementation
│   ├── variables.tf         # Input variables with validation
│   ├── outputs.tf           # Module outputs
│   └── README.md            # Module documentation
├── examples/complete/        # Complete usage example
│   ├── main.tf              # Example implementation
│   ├── containers.yaml      # Example container configurations
│   └── README.md            # Example documentation
├── containers.yaml          # Container definitions (single source of truth)
├── containers.tf            # Root module calling LXC module
├── providers.tofu           # Provider configuration
├── variables.tofu           # Root module variables
└── README.md               # This file
```

## 🛠️ Quick Start

### 1. Configure Provider

Set your Proxmox credentials:

```bash
export TF_VAR_endpoint="https://your-proxmox-host:8006/api2/json"
export TF_VAR_username="root@pam"
export TF_VAR_password="your-password"
```

### 2. Define Containers

Edit `containers.yaml` to define your containers:

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

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## 📚 Documentation

### **Getting Started**

- [Quick Start Guide](QUICK_START.md) - Get up and running quickly
- [LXC Configuration Guide](LXC_CONFIGURATION_GUIDE.md) - Comprehensive configuration guide
- [Module Documentation](modules/lxc/README.md) - Module reference

### **Important Limitations & Solutions**

- [Cloning and Initialization](CLONING_AND_INITIALIZATION.md) - **READ THIS FIRST!** Explains why `initialization` doesn't work with cloning
- [Converting Container to Template](CONVERTING_CONTAINER_TO_TEMPLATE.md) - How to convert containers to OS templates
- [Quick Reference: Template Conversion](QUICK_REFERENCE_TEMPLATE_CONVERSION.md) - Quick commands
- [Complete Solution Summary](COMPLETE_SOLUTION_SUMMARY.md) - Overview of all solutions

### **Examples**

- [Complete Example](examples/complete/README.md) - Full working example
- [OS Template vs Clone Comparison](examples/os-template-vs-clone-comparison.yaml) - Side-by-side comparison

### **Scripts**

- [Convert Container to Template](scripts/convert-container-to-template.sh) - Automated conversion script

### **External Resources**

- [Proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Linux_Container)

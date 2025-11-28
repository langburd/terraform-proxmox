# Additional network interfaces
variable "additional_network_interfaces" {
  description = "Additional network interfaces"
  type = list(object({
    name        = string
    bridge      = optional(string, "vmbr0")
    enabled     = optional(bool, true)
    firewall    = optional(bool, false)
    mac_address = optional(string)
    mtu         = optional(number)
    rate_limit  = optional(number)
    vlan_id     = optional(number)
  }))
  default = []
}

variable "app_password" {
  default     = null
  description = "The password for the root user of the LXC containers"
  sensitive   = true
  type        = string
}

# Clone configuration
variable "clone" {
  description = "Clone configuration for creating container from template"
  type = object({
    vm_id        = number
    datastore_id = optional(string)
    node_name    = optional(string)
    full         = optional(bool, true)
  })
  default = null
}

# Console configuration
variable "console" {
  description = "Console configuration"
  type = object({
    enabled = optional(bool, true)
    tty     = optional(number, 2)
    type    = optional(string, "console")
  })
  default = {
    enabled = true
    tty     = 2
    type    = "console"
  }
}

# CPU and memory configuration
variable "cpu" {
  description = "The CPU configuration"
  type = object({
    architecture = optional(string, "amd64")
    cores        = optional(number, 1)
    units        = optional(number, 1024)
  })
  default = {
    architecture = "amd64"
    cores        = 1
    units        = 1024
  }

  validation {
    condition     = var.cpu.cores >= 1 && var.cpu.cores <= 128
    error_message = "CPU cores must be between 1 and 128."
  }

  validation {
    condition     = var.cpu.units >= 8 && var.cpu.units <= 500000
    error_message = "CPU units must be between 8 and 500000."
  }

  validation {
    condition     = contains(["amd64", "arm64", "i386"], var.cpu.architecture)
    error_message = "CPU architecture must be one of: amd64, arm64, i386."
  }
}

variable "description" {
  description = "The description of the container"
  type        = string
  default     = "Managed by Terraform"
}

# Disk configuration
variable "disk" {
  description = "The disk configuration (null when cloning)"
  type = object({
    datastore_id = string
    size         = optional(number, 8)
  })
  default = null
}

# Features configuration
variable "features" {
  description = "Container features configuration"
  type = object({
    fuse    = optional(bool, false)
    keyctl  = optional(bool, false)
    mount   = optional(list(string), [])
    nesting = optional(bool, false)
  })
  default = {}
}

# Hook script configuration
variable "hook_script_file_id" {
  description = "The identifier for a file containing a hook script"
  type        = string
  default     = null
}

# Initialization configuration
variable "initialization" {
  description = "Container initialization configuration"
  type = object({
    hostname = optional(string)
    dns = optional(object({
      domain  = optional(string)
      servers = optional(list(string), [])
    }))
    ip_config = optional(object({
      ipv4 = optional(object({
        address = optional(string)
        gateway = optional(string)
      }))
      ipv6 = optional(object({
        address = optional(string)
        gateway = optional(string)
      }))
    }))
    user_account = optional(object({
      keys     = optional(list(string), [])
      password = optional(string)
    }))
  })
  default = {}
}

variable "memory" {
  description = "The memory configuration"
  type = object({
    dedicated = optional(number, 512)
    swap      = optional(number, 0)
  })
  default = {
    dedicated = 512
    swap      = 0
  }

  validation {
    condition     = var.memory.dedicated >= 16 && var.memory.dedicated <= 268435456
    error_message = "Dedicated memory must be between 16 MB and 256 GB (268435456 MB)."
  }

  validation {
    condition     = var.memory.swap >= 0 && var.memory.swap <= 268435456
    error_message = "Swap memory must be between 0 and 256 GB (268435456 MB)."
  }
}

# Mount points configuration
variable "mount_point" {
  description = "Mount point configurations"
  type = list(object({
    volume    = string
    path      = string
    backup    = optional(bool, false)
    quota     = optional(bool, false)
    read_only = optional(bool, false)
    replicate = optional(bool, true)
    shared    = optional(bool, false)
    size      = optional(string)
  }))
  default = []
}

# Network interface configuration
variable "network_interface" {
  description = "Network interface configuration"
  type = object({
    name        = optional(string, "veth0")
    bridge      = optional(string, "vmbr0")
    enabled     = optional(bool, true)
    firewall    = optional(bool, false)
    mac_address = optional(string)
    mtu         = optional(number)
    rate_limit  = optional(number)
    vlan_id     = optional(number)
  })
  default = {
    name    = "veth0"
    bridge  = "vmbr0"
    enabled = true
  }
}

# Core container configuration
variable "node_name" {
  description = "The name of the Proxmox VE node where the container will be created"
  type        = string

  validation {
    condition     = length(var.node_name) > 0
    error_message = "Node name cannot be empty."
  }
}

# Operating system configuration
variable "operating_system" {
  description = "The operating system configuration (null when cloning)"
  type = object({
    template_file_id = string
    type             = optional(string, "debian")
  })
  default = null
}

# Pool configuration
variable "pool_id" {
  description = "The identifier for a pool to assign the container to"
  type        = string
  default     = null
}

variable "protection" {
  description = "Whether the container is protected from deletion"
  type        = bool
  default     = false
}

variable "ssh_key" {
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChfZryPRwPcle2fzNjZkjzDiTLOLBvDAx+Vj1zyMEMkoTGA7e8t0p6uuuQaL1ifunjlN7WvhTbvJYy4YNU1/YCN8g99SvZHpJxRDq0qti9W2DUeSdagw6+wSL0ZLseLbDpT4QMJzuGM8y/nkJVUcxTg08GGhDzLdjLxQRI37CTsrt3mShEnf0wp+SYC0hYjKXdYQo27VBNIIsa/MuuOfhgvg7lqM2vvQhCD/8MjHtwOZe8ae342JbK6bzyfBscLbXhxIw2+cIV8MFmvG4DeMCg71h1xfNR8ic9XW9OeW6nJZz4Fm1uysSZnrc24jsoNRl1taWPoCY/S3EvGzM+Hlxz avi@langburd.com"
  description = "The SSH public key for the root user of the LXC containers"
  type        = string
}

# Started state
variable "started" {
  description = "Whether the container should be started after creation"
  type        = bool
  default     = true
}

# Startup configuration
variable "startup" {
  description = "Startup and shutdown behavior configuration"
  type = object({
    order      = optional(string)
    up_delay   = optional(string)
    down_delay = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A list of tags to assign to the container"
  type        = list(string)
  default     = []
}

variable "template" {
  description = "Whether this container is a template"
  type        = bool
  default     = false
}

variable "unprivileged" {
  description = "Whether the container runs as unprivileged on the host"
  type        = bool
  default     = true
}

variable "vm_id" {
  description = "The unique identifier of the container (if not specified, the next available ID will be used)"
  type        = number
  default     = null
}

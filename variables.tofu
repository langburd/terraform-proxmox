variable "endpoint" {
  description = "The Proxmox VE API endpoint."
  type        = string
}

variable "username" {
  default     = "root@pam"
  description = "The Proxmox VE username. Some operations not supported with API token."
  type        = string
}

variable "password" {
  default     = null
  description = "The Proxmox VE password. Some operations not supported with API token."
  sensitive   = true
  type        = string
}

variable "app_password" {
  default     = null
  description = "The password for the root user of the LXC containers"
  sensitive   = true
  type        = string
}

# Parse containers.yaml file
locals {
  containers      = local.containers_yaml.containers
  containers_yaml = yamldecode(file("${path.root}/containers.yaml"))
  # Filter containers that need Docker AppArmor workaround
  # This is needed for Proxmox < 9.1 where Docker in LXC has AppArmor issues
  docker_containers = {
    for name, config in local.containers : name => config
    if try(config.docker_apparmor_fix, false) == true
  }
}

# Create LXC containers using the module
module "lxc_containers" {
  source = "./modules/lxc"

  for_each = local.containers

  # Core configuration
  node_name    = each.value.node_name
  vm_id        = try(each.value.vm_id, null)
  description  = try(each.value.description, "Managed by Terraform")
  tags         = try(each.value.tags, [])
  template     = try(each.value.template, false)
  unprivileged = try(each.value.unprivileged, false)
  protection   = try(each.value.protection, false)
  # If docker_apparmor_fix is enabled, create container stopped so we can apply
  # the AppArmor workaround before the first start
  started = try(each.value.docker_apparmor_fix, false) ? false : try(each.value.started, true)

  # Ensure hook scripts are created before containers that reference them
  depends_on = [
    proxmox_virtual_environment_file.alpine_docker_setup
  ]

  # Operating system configuration (only if not cloning)
  operating_system = try(each.value.clone, null) == null ? {
    template_file_id = each.value.operating_system.template_file_id
    type             = try(each.value.operating_system.type, "debian")
  } : null

  # CPU configuration
  cpu = {
    architecture = try(each.value.cpu.architecture, "amd64")
    cores        = try(each.value.cpu.cores, 1)
    units        = try(each.value.cpu.units, 1024)
  }

  # Memory configuration
  memory = {
    dedicated = try(each.value.memory.dedicated, 512)
    swap      = try(each.value.memory.swap, 0)
  }

  # Disk configuration (only if not cloning)
  disk = try(each.value.clone, null) == null ? {
    datastore_id = try(each.value.disk.datastore_id, "lenovo16-ssd")
    size         = try(each.value.disk.size, 8)
  } : null

  # Network interface configuration
  network_interface = {
    name        = try(each.value.network_interface.name, "veth0")
    bridge      = try(each.value.network_interface.bridge, "vmbr0")
    enabled     = try(each.value.network_interface.enabled, true)
    firewall    = try(each.value.network_interface.firewall, false)
    mac_address = try(each.value.network_interface.mac_address, null)
    mtu         = try(each.value.network_interface.mtu, null)
    rate_limit  = try(each.value.network_interface.rate_limit, null)
    vlan_id     = try(each.value.network_interface.vlan_id, null)
  }

  # Additional network interfaces
  additional_network_interfaces = try(each.value.additional_network_interfaces, [])

  # Initialization configuration (only if not cloning)
  # When cloning, initialization must be null to avoid Proxmox API errors
  initialization = try(each.value.clone, null) == null ? try(each.value.initialization, {}) : null

  # Mount points
  mount_point = try(each.value.mount_point, [])

  # Console configuration
  console = {
    enabled = try(each.value.console.enabled, true)
    tty     = try(each.value.console.tty, 2)
    type    = try(each.value.console.type, "console")
  }

  # Features configuration
  features = try(each.value.features, {})

  # Optional configurations
  hook_script_file_id = try(each.value.hook_script_file_id, null)
  pool_id             = try(each.value.pool_id, null)

  # Startup configuration
  startup = try(each.value.startup, null)

  # Clone configuration
  clone = try(each.value.clone, null)

  app_password = var.app_password
}

# Deploy hook script for Alpine Docker containers
# The script is stored externally for better maintainability and version control
# See: scripts/alpine-docker-setup.sh
resource "proxmox_virtual_environment_file" "alpine_docker_setup" {
  content_type = "snippets"
  datastore_id = "lenovo16-hdd"
  node_name    = "hpelite32"

  # Hook scripts must be executable, otherwise Proxmox VE API will reject the VM/CT configuration
  file_mode = "0700"

  source_file {
    path      = "${path.root}/scripts/alpine-docker-setup.sh"
    file_name = "alpine-docker-setup.sh"
  }
}

resource "null_resource" "docker_apparmor_fix" {
  for_each = local.docker_containers

  # Trigger re-run if the container is recreated
  triggers = {
    container_id = module.lxc_containers[each.key].vm_id
    node_name    = module.lxc_containers[each.key].node_name
  }

  # Wait for container to be created
  depends_on = [module.lxc_containers]

  connection {
    type     = "ssh"
    host     = "${each.value.node_name}.baza.ddyy.pro"
    user     = "root"
    password = var.password
    # private_key = file("~/.ssh/langburd")
    timeout = "2m"
  }

  # Upload the AppArmor workaround script to Proxmox host
  provisioner "file" {
    source      = "${path.module}/scripts/docker-apparmor-fix.sh"
    destination = "/tmp/docker-apparmor-fix.sh"
  }

  # Execute the script with the container VMID as argument
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/docker-apparmor-fix.sh",
      "/tmp/docker-apparmor-fix.sh ${module.lxc_containers[each.key].vm_id}",
      "rm -f /tmp/docker-apparmor-fix.sh"
    ]
  }
}

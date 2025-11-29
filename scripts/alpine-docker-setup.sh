#!/bin/bash
# Proxmox LXC Hook Script for Alpine Docker containers
# This script runs on the Proxmox HOST, not inside the container
#
# Arguments:
#   $1 - VMID (container ID)
#   $2 - Phase: pre-start, post-start, pre-stop, post-stop
#
# To execute commands inside the container, use: pct exec $VMID -- <command>

VMID="$1"
PHASE="$2"
LOGFILE="/var/log/lxc-hookscript.log"

# Log function for debugging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VMID:$VMID] [$PHASE] $1" >> "$LOGFILE"
}

# Execute command inside container with error handling
exec_in_container() {
    local cmd="$1"
    local description="$2"
    log "Executing: $description"
    if pct exec "$VMID" -- sh -c "$cmd" >> "$LOGFILE" 2>&1; then
        log "Success: $description"
        return 0
    else
        log "Failed: $description (exit code: $?)"
        return 1
    fi
}

log "Hook script started"

# Marker file to track if initial setup has been completed
# This prevents re-running setup on subsequent container starts/reboots
SETUP_MARKER="/var/lib/.docker-setup-complete"

case "$PHASE" in
    post-start)
        log "Running post-start phase for Alpine Docker container"

        # Check if initial setup has already been completed
        if pct exec "$VMID" -- test -f "$SETUP_MARKER" 2>/dev/null; then
            log "Setup marker found - initial setup already completed, skipping"
            log "Hook script finished (no action needed)"
            exit 0
        fi

        log "No setup marker found - running initial configuration"

        # Wait for container to be fully up and network ready
        log "Waiting for container to be fully up..."
        sleep 10

        # Wait for network connectivity inside container
        log "Checking network connectivity..."
        for i in $(seq 1 30); do
            if pct exec "$VMID" -- ping -c 1 -W 2 dl-cdn.alpinelinux.org >/dev/null 2>&1; then
                log "Network is ready"
                break
            fi
            if [ "$i" -eq 30 ]; then
                log "ERROR: Network not available after 30 attempts"
                exit 1
            fi
            log "Waiting for network... attempt $i/30"
            sleep 2
        done

        # Update package repositories
        exec_in_container "apk update" "Updating package repositories" || exit 1

        # Install essential packages including SSH
        log "Installing essential packages..."
        exec_in_container "apk add --no-cache bind-tools openssh tzdata curl bash nano net-tools mc" "Installing base packages" || exit 1

        # Install Python 3 and Ansible prerequisites
        # These packages are required for Ansible to run playbooks on this container:
        # - python3: Python interpreter required by Ansible modules
        # - py3-pip: Python package manager for installing additional Python dependencies
        # - python3-dev: Development headers needed for compiling Python extensions
        # - libffi-dev: Required for some Ansible modules that use cffi
        # - openssl-dev: Required for cryptography-related Ansible operations
        # - musl-dev: C library development files needed for Python package compilation
        # - gcc: Compiler needed for building Python packages from source
        log "Installing Python 3 and Ansible prerequisites..."
        exec_in_container "apk add --no-cache python3 py3-pip python3-dev libffi-dev openssl-dev musl-dev gcc" "Installing Python 3 and Ansible prerequisites" || exit 1

        # Ensure python3 is available at /usr/bin/python3 (create symlink if needed)
        # Alpine may install python3 in different locations depending on version
        exec_in_container "[ -f /usr/bin/python3 ] || ln -sf \$(which python3) /usr/bin/python3" "Ensuring python3 symlink"

        # Verify Python installation
        PYTHON_VERSION=$(pct exec "$VMID" -- python3 --version 2>/dev/null || echo "unknown")
        log "Python version: $PYTHON_VERSION"

        # Configure and start SSH
        log "Configuring SSH..."
        exec_in_container "rc-update add sshd default" "Enabling sshd at boot"
        exec_in_container "rc-service sshd start" "Starting sshd"

        # Install Docker
        log "Installing Docker..."
        exec_in_container "apk add --no-cache docker docker-cli docker-cli-compose" "Installing Docker packages" || exit 1

        # Enable Docker to start at boot
        log "Enabling Docker at boot..."
        exec_in_container "rc-update add docker default" "Enabling Docker at boot" || exit 1

        # Verify Docker installation
        DOCKER_VERSION=$(pct exec "$VMID" -- docker --version 2>/dev/null || echo "unknown")
        log "Docker version: $DOCKER_VERSION"

        # Verify Docker Compose installation
        COMPOSE_VERSION=$(pct exec "$VMID" -- docker compose version 2>/dev/null || echo "unknown")
        log "Docker Compose version: $COMPOSE_VERSION"

        log "========================================"
        log "Alpine Docker container setup complete!"
        log "Python: $PYTHON_VERSION"
        log "Docker: $DOCKER_VERSION"
        log "Docker Compose: $COMPOSE_VERSION"
        log "========================================"

        # Create setup marker file to prevent re-running on subsequent starts
        log "Creating setup marker file..."
        exec_in_container "touch $SETUP_MARKER" "Creating setup marker"

        # Note: Docker will be started via init system after the container is rebooted.
        # The reboot is handled by the docker_apparmor_fix script after the hook script
        # completes, because processes started via pct exec during hook scripts are
        # terminated when the hook script exits.
        log "Initial setup complete - container will be rebooted by docker_apparmor_fix script"
        ;;
    pre-start)
        log "Pre-start phase - no action needed"
        ;;
    pre-stop)
        log "Pre-stop phase - no action needed"
        ;;
    post-stop)
        log "Post-stop phase - no action needed"
        ;;
    *)
        log "Unknown phase: $PHASE"
        ;;
esac

log "Hook script finished"
exit 0

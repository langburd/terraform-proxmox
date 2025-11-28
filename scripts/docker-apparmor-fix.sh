#!/bin/bash
set -e

# Docker workaround script for Proxmox LXC containers (CVE-2025-52881)
# This script applies the necessary LXC configuration to allow Docker to run
# inside containers with nesting enabled.
#
# Usage: docker-apparmor-fix.sh <VMID>
#
# Required configuration lines:
# 1. lxc.apparmor.profile: unconfined - disables AppArmor checks
# 2. lxc.cgroup2.devices.allow: a - allows all device access
# 3. lxc.cap.drop: - prevents dropping any capabilities (empty value)
# 4. lxc.mount.entry - tricks runc into thinking AppArmor is disabled
#
# See: https://github.com/opencontainers/runc/issues/4968
# See: https://forum.proxmox.com/threads/cve-2025-52881-breaks-docker-lxc-containers.175827/
# See: https://github.com/blakeblackshear/frigate/discussions/1111

if [[ -z "$1" ]]; then
  echo "ERROR: VMID argument required"
  echo "Usage: $0 <VMID>"
  exit 1
fi

VMID="$1"
CONF_FILE="/etc/pve/lxc/${VMID}.conf"
LOG_FILE='/var/log/terraform-apparmor-fix.log'

# Logging function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VMID:${VMID}] $1" | tee -a "${LOG_FILE}"
}

log '=============================================='
log 'Starting Docker workaround for Proxmox LXC'
log '=============================================='

# Check if configuration file exists
if [[ ! -f "${CONF_FILE}" ]]; then
  log "ERROR: Configuration file not found: ${CONF_FILE}"
  exit 1
fi

log "Configuration file: ${CONF_FILE}"

# Debug: Show current config before changes
log 'Current LXC configuration (before changes):'
log '----------------------------------------------'
cat "${CONF_FILE}" | while read line; do log "  $line"; done
log '----------------------------------------------'

# Check if workaround is already applied (check for all required lines)
APPARMOR_OK=$(grep -c 'lxc.apparmor.profile: unconfined' "${CONF_FILE}" 2>/dev/null || echo 0)
CGROUP_OK=$(grep -c 'lxc.cgroup2.devices.allow: a' "${CONF_FILE}" 2>/dev/null || echo 0)
CAPDROP_OK=$(grep -c '^lxc.cap.drop:' "${CONF_FILE}" 2>/dev/null || echo 0)
MOUNT_OK=$(grep -c 'sys/module/apparmor/parameters/enabled' "${CONF_FILE}" 2>/dev/null || echo 0)

log "Workaround status check:"
log "  - lxc.apparmor.profile: unconfined: $([ $APPARMOR_OK -gt 0 ] && echo 'PRESENT' || echo 'MISSING')"
log "  - lxc.cgroup2.devices.allow: a: $([ $CGROUP_OK -gt 0 ] && echo 'PRESENT' || echo 'MISSING')"
log "  - lxc.cap.drop: (empty): $([ $CAPDROP_OK -gt 0 ] && echo 'PRESENT' || echo 'MISSING')"
log "  - lxc.mount.entry (apparmor): $([ $MOUNT_OK -gt 0 ] && echo 'PRESENT' || echo 'MISSING')"

if [[ $APPARMOR_OK -gt 0 ]] && [[ $CGROUP_OK -gt 0 ]] && [[ $CAPDROP_OK -gt 0 ]] && [[ $MOUNT_OK -gt 0 ]]; then
  log 'All Docker workaround lines already applied'
  STATUS=$(pct status ${VMID} 2>/dev/null | awk '{print $2}')
  if [[ "${STATUS}" == 'stopped' ]]; then
    log 'Container is stopped, starting it...'
    pct start ${VMID}
    log 'Container started'
  else
    log "Container status: ${STATUS}"
  fi
  exit 0
fi

log 'Applying Docker workaround configuration to stopped container...'

# Remove any partial/old workaround lines to avoid duplicates
log 'Removing any existing partial workaround lines...'
sed -i '/lxc.apparmor.profile: unconfined/d' "${CONF_FILE}"
sed -i '/lxc.cgroup.devices.allow: a/d' "${CONF_FILE}"
sed -i '/lxc.cgroup2.devices.allow: a/d' "${CONF_FILE}"
sed -i '/^lxc.cap.drop:/d' "${CONF_FILE}"
sed -i '/sys\/module\/apparmor\/parameters\/enabled/d' "${CONF_FILE}"

# Add Docker workaround configuration for CVE-2025-52881
# All four lines are required for Docker to work in LXC:
# NOTE: Comments are NOT added to the config file to avoid affecting the
# Proxmox API's description field parsing
log 'Adding Docker workaround configuration...'
{
  echo 'lxc.apparmor.profile: unconfined'
  echo 'lxc.cgroup2.devices.allow: a'
  echo 'lxc.cap.drop:'
  echo 'lxc.mount.entry: /dev/null sys/module/apparmor/parameters/enabled none bind 0 0'
} >> "${CONF_FILE}"

log 'Docker workaround configuration applied'

# Debug: Show config after changes
log 'LXC configuration (after changes):'
log '----------------------------------------------'
cat "${CONF_FILE}" | while read line; do log "  $line"; done
log '----------------------------------------------'

# Verify the lines were added
log 'Verification:'
grep -E '(lxc.apparmor.profile|lxc.cgroup2.devices.allow|lxc.cap.drop|sys/module/apparmor)' "${CONF_FILE}" | while read line; do
  log "  VERIFIED: $line"
done

log 'Starting container for the first time with Docker workaround...'
pct start ${VMID}

# Wait for container to start
for i in $(seq 1 60); do
  STATUS=$(pct status ${VMID} 2>/dev/null | awk '{print $2}')
  if [[ "${STATUS}" == 'running' ]]; then
    log 'Container started successfully'
    break
  fi
  sleep 1
done

# Verify container is running
FINAL_STATUS=$(pct status ${VMID} 2>/dev/null | awk '{print $2}')
if [[ "${FINAL_STATUS}" != 'running' ]]; then
  log 'ERROR: Container failed to start after Docker workaround'
  exit 1
fi

# Check if the container has a hook script that sets up Docker
# If so, we need to reboot the container to start Docker via init system
# because processes started via pct exec during hook scripts are terminated
HOOK_SCRIPT=$(grep -E '^hookscript:' "${CONF_FILE}" 2>/dev/null | awk '{print $2}')
if [[ -n "${HOOK_SCRIPT}" && "${HOOK_SCRIPT}" == *"alpine-docker-setup"* ]]; then
  log 'Container has Docker setup hook script - rebooting to start Docker via init system...'
  pct reboot ${VMID}

  # Wait for container to come back up
  log 'Waiting for container to restart...'
  sleep 5
  for i in $(seq 1 60); do
    STATUS=$(pct status ${VMID} 2>/dev/null | awk '{print $2}')
    if [[ "${STATUS}" == 'running' ]]; then
      log 'Container restarted successfully - Docker should now be running via init system'
      break
    fi
    sleep 1
  done
fi

log '=============================================='
log 'Docker workaround completed successfully'
log '=============================================='

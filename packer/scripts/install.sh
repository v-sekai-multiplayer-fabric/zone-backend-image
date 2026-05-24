#!/usr/bin/env bash
# Provisioner: layers gateway VM bits on top of linux-base-image.
# Runs as root via `sudo -E bash`.
set -euo pipefail

install -d -m 0755 /etc/containers/systemd
install -m 0644 /tmp/quadlets/*.container /etc/containers/systemd/
rm -rf /tmp/quadlets

# Mountpoints for cert material delivered at first boot.
install -d -m 0750 /etc/gateway/db-certs
install -d -m 0750 /etc/gateway/tls

# Pre-pull the gateway image so first boot is fast. Tag pinned here;
# bumping it is a deliberate change to this repo (and re-bake).
podman pull ghcr.io/v-sekai-multiplayer-fabric/zone-backend:latest || \
  echo "Warning: zone-backend:latest pull failed; first boot will pull on demand"

dnf clean all
cloud-init clean --logs
: > /etc/machine-id
rm -f /var/lib/dbus/machine-id || true
fstrim -av || true

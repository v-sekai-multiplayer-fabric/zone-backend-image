#!/usr/bin/env bash
# Install the zone-backend (URO) podman quadlet onto this host.
#
# Copies the quadlet unit(s) in ./quadlets into the system quadlet
# directory, creates the cert mountpoints, optionally pre-pulls the
# image, and reloads systemd.
#
# Service env file is NOT created here; deployments drop it at runtime:
#   /etc/zone-backend/env -> DATABASE_URL, MIGRATION_URL,
#                            SECRET_KEY_BASE, per-deployment Phoenix config
#
# Run as root:  sudo ./install.sh
# Skip the pre-pull with:  PULL=0 sudo -E ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
QUADLET_DST=/etc/containers/systemd
PULL="${PULL:-1}"

[ "$(id -u)" -eq 0 ] || { echo "must run as root" >&2; exit 1; }

install -d -m 0755 "$QUADLET_DST"
install -m 0644 "$REPO_DIR"/quadlets/*.container "$QUADLET_DST"/

# Cert mountpoints delivered per-deployment.
install -d -m 0750 /etc/zone-backend/db-certs   # CRDB mTLS client certs
install -d -m 0750 /etc/zone-backend/tls         # public TLS cert

if [ "$PULL" = "1" ]; then
  # Tag pinned in quadlets/zone-backend.container.
  podman pull ghcr.io/v-sekai-multiplayer-fabric/zone-backend:latest || \
    echo "Warning: zone-backend pull failed; first start will pull on demand"
fi

systemctl daemon-reload
echo "Installed. Write /etc/zone-backend/env, then: systemctl start zone-backend.service"

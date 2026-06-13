# zone-backend-quadlet

Podman [quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
source for [zone-backend](https://github.com/v-sekai-multiplayer-fabric/zone-backend)
(URO) — an Elixir/Phoenix backend hosting identity, the zone directory,
and the planner JSON surface (plan / replan / rebac_check / ping). Run
by systemd on an AlmaLinux host.

This repo is the source of truth for the unit; it is installed onto a
host rather than baked into a VM image.

## Layout

- `quadlets/zone-backend.container` — the quadlet, publishing UDP/443
  (HTTP/3 / WebTransport client surface; Phoenix HTTP/JSON shares it via
  h3). Tag pinned here.
- `install.sh` — installs the unit, creates `/etc/zone-backend/db-certs`
  (CRDB mTLS client certs) and `/etc/zone-backend/tls` (public TLS cert)
  mountpoints, pre-pulls the image, reloads systemd.

## Install

```sh
sudo ./install.sh
# write /etc/zone-backend/env (see below)
sudo systemctl start zone-backend.service
```

## Configuration (per-deployment, NOT in this repo)

- `/etc/zone-backend/env` — `DATABASE_URL`, `MIGRATION_URL`,
  `SECRET_KEY_BASE`, and any per-deployment Phoenix config.
- `/etc/zone-backend/db-certs` — CRDB mTLS client certs
  (gateway_writer / gateway_reader).
- `/etc/zone-backend/tls` — public TLS cert.

## CI

`.github/workflows/lint.yml` validates the unit via podman's systemd
generator on every push/PR.

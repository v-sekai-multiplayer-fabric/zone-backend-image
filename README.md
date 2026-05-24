# zone-backend-image

V-Sekai zone-backend VM image: [zone-backend](https://github.com/v-sekai-multiplayer-fabric/zone-backend)
(URO), an Elixir/Phoenix backend that hosts identity, the zone directory,
and the planner JSON surface (plan / replan / rebac_check / ping). Run
as a podman quadlet on top of `linux-base-image`. Built once per release
via packer; consumed by the `infra` repo as the qcow2 for
`harvester_virtualmachine.zone_backend`.

## What's in the image

Inherits everything from `linux-base-image` (AlmaLinux 9 + podman +
chrony + qemu-guest-agent), and adds:

- `/etc/containers/systemd/zone-backend.container` — podman quadlet
  running `ghcr.io/v-sekai-multiplayer-fabric/zone-backend`
- `/etc/zone-backend/db-certs` — mountpoint for the CRDB mTLS client
  certs (gateway_writer / gateway_reader roles, talking to the
  cockroach-crdb-image VM)
- `/etc/zone-backend/tls` — mountpoint for the Let's Encrypt cert
  serving the public client surface

The zone-backend image is pre-pulled into podman's local store so
first boot is fast. Tag pinned in
`configs/quadlets/zone-backend.container`; bumping is a deliberate
edit + re-bake.

Service env file (`/etc/zone-backend/env`) is not baked. The infra
side writes it at first boot with `DATABASE_URL`, `MIGRATION_URL`,
`SECRET_KEY_BASE`, and any per-deployment Phoenix config so the same
image is reusable across deployments.

## Build

CI on push to main + weekly schedule. Local:

```sh
cd packer
bash scripts/prepare-cidata.sh
packer init build.pkr.hcl
packer build build.pkr.hcl
ls ../output/
```

## Inheritance

Pin the parent version explicitly in `build.pkr.hcl`:

```hcl
variable "source_image_url" {
  default = "https://github.com/v-sekai-multiplayer-fabric/linux-base-image/releases/download/v0.1.0/linux-base-image.qcow2"
}
```

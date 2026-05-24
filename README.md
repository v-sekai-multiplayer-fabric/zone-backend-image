# zone-backend-image

V-Sekai gateway VM image: the zone-backend Elixir/Phoenix release run
as a podman quadlet on top of `linux-base-image`. Built once per
release via packer; consumed by the `infra` repo as the qcow2 for
`harvester_virtualmachine.gateway`.

## What's in the image

Inherits everything from `linux-base-image` (AlmaLinux 9 + podman +
chrony + qemu-guest-agent), and adds:

- `/etc/containers/systemd/gateway.container` — podman quadlet
  running `ghcr.io/v-sekai-multiplayer-fabric/zone-backend`
- `/etc/gateway/db-certs` — mountpoint for CRDB mTLS client certs
  (gateway_writer / gateway_reader roles)
- `/etc/gateway/tls` — mountpoint for the Let's Encrypt cert that
  terminates WebTransport on UDP/443

The zone-backend image is pre-pulled into podman's local store so first
boot is fast. Tag pinned in `configs/quadlets/gateway.container`;
bumping is a deliberate edit + re-bake.

Service env file (`/etc/gateway/env`) is not baked. The infra side
writes it at first boot with `DATABASE_URL`, `MIGRATION_URL`, and any
runtime secrets so the same image is reusable across deployments.

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

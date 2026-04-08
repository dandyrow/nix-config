# nix-config

NixOS and Home Manager configurations. Dotfiles are managed separately in
[dandyrow/dotfiles](https://github.com/dandyrow/dotfiles) and pulled in as a
flake input that creates live symlinks from `~/.dotfiles`, so dotfile content
can be edited in place without re-running a switch.

## Repository structure

```
flake.nix                        # Entry point — all inputs and outputs
home/
  default.nix                    # Home Manager config shared by every machine
  profiles/                      # Role-specific HM additions (desktop, server)
hosts/
  <hostname>/
    configuration.nix            # Machine-specific NixOS config
    disk-config.nix              # Declarative disk layout (disko)
    hardware-configuration.nix   # Hardware-specific kernel modules and settings
modules/
  common/                        # Shared NixOS config (all hosts)
  desktop/                       # Desktop NixOS config (GNOME, Wayland, Steam)
  server/                        # Server NixOS config
  vm/                            # VM guest config (QEMU guest agent)
```

## Machines

| Hostname | Type | Config |
|---|---|---|
| `DansSpectre` | NixOS — HP Spectre x360 15-ch005na | GNOME, Wayland, AMD GPU (Vega M GL) |
| `New-H0Ryzen` | NixOS — QEMU/KVM VM on Proxmox | GNOME, Wayland, NVIDIA (VFIO passthrough) |
| `dandyrow` | Standalone Home Manager — WSL | Base dotfiles only |

## Installing NixOS on a new machine

Installation is handled by [nixos-anywhere](https://github.com/nix-community/nixos-anywhere),
which SSHes into the target machine (booted from the NixOS minimal installer ISO),
uses [disko](https://github.com/nix-community/disko) to partition and format
the disk, then installs NixOS from this flake.

**Prerequisites:** the target machine must be running and reachable over SSH as `root`.

The `dandyrow` user account requires a hashed password to be injected at install
time. The hash is written to `/etc/secrets/dandyrow-password` on the target via
`--extra-files` and is never committed to the repo.

```bash
# Prompt for a password and generate a sha-512 hash (requires whois/mkpasswd)
HASH=$(mkpasswd -m sha-512)

# Stage the hash as a file for nixos-anywhere to place on the target
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/etc/secrets"
echo "$HASH" > "$TMPDIR/etc/secrets/dandyrow-password"

nix run github:nix-community/nixos-anywhere -- \
  --extra-files "$TMPDIR" \
  --flake .#<hostname> root@<ip>

rm -rf "$TMPDIR"
```

After the install completes nixos-anywhere reboots the machine into the new system.
Home Manager runs automatically on first login and clones `~/.dotfiles` via the
activation script in `home/default.nix`.

## Updating an existing NixOS system

Run on the machine itself after pulling the latest config:

```bash
nixos-rebuild switch --flake .#<hostname>
```

Or build and switch remotely:

```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<ip>
```

## Bootstrapping Home Manager (non-NixOS machines)

For any machine with Nix installed but not running NixOS (e.g. WSL), run once:

```bash
NIX_CONFIG="experimental-features = nix-command flakes" \
  nix run home-manager/release-24.11 -- switch \
  --flake github:dandyrow/nix-config#dandyrow --refresh
```

On subsequent updates (after flakes are enabled in `~/.config/nix/nix.conf`):

```bash
home-manager switch --flake github:dandyrow/nix-config#dandyrow --refresh
```

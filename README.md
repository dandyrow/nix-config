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

```bash
./scripts/install.sh <hostname> <ip> [ssh-user] [build-on]
```

| Argument | Description | Default |
|---|---|---|
| `hostname` | Name of the `nixosConfiguration` to install | prompted |
| `ip` | IP address of the target machine | prompted |
| `ssh-user` | SSH user to connect to the target as | `root` |
| `build-on` | Where Nix builds happen: `local`, `remote`, or `auto` | `auto` |

All arguments are optional — the script will prompt for any that are missing.
`build-on remote` causes the target machine to download and build everything
itself, which avoids transferring large store paths over SSH.

The script validates the hostname against the flake, prompts for the `dandyrow`
user password (with confirmation), hashes it, and passes it to nixos-anywhere
via `--extra-files` so it is never written to disk in plaintext or committed to
the repo. `mkpasswd` is used automatically via `nix-shell` if not already on PATH.

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

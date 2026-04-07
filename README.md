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
  profiles/
    desktop.nix                  # Additional HM config for desktop/laptop machines
    server.nix                   # Additional HM config for servers
hosts/
  New-H0Ryzen/
    configuration.nix            # Machine-specific NixOS config
    disk-config.nix              # Declarative disk layout (disko)
    hardware-configuration.nix   # QEMU hardware config
modules/
  common/                        # Shared NixOS config (all hosts)
  desktop/                       # Desktop NixOS config (GNOME, Wayland, NVIDIA)
  server/                        # Server NixOS config
  vm/                            # VM guest config (QEMU guest agent)
```

## Machines

| Hostname | Type | Config |
|---|---|---|
| `New-H0Ryzen` | NixOS — QEMU/KVM VM on Proxmox | GNOME, Wayland, NVIDIA (VFIO passthrough) |
| `dandyrow` | Standalone Home Manager — WSL | Base dotfiles only |

## Installing NixOS (New-H0Ryzen)

Installation is handled by [nixos-anywhere](https://github.com/nix-community/nixos-anywhere),
which SSHes into the target VM (booted from the NixOS minimal installer ISO),
uses [disko](https://github.com/nix-community/disko) to partition and format
the disk, then installs NixOS from this flake.

**Prerequisites:** the target VM must be running and reachable over SSH as `root`.

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#New-H0Ryzen root@<vm-ip>
```

After the install completes nixos-anywhere reboots the VM into the new system.
Home Manager runs automatically on first login and clones `~/.dotfiles` via the
activation script in `home/default.nix`.

## Updating an existing NixOS system

```bash
nixos-rebuild switch --flake .#New-H0Ryzen
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

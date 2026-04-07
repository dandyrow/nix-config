{ inputs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/common/default.nix
    ../../modules/desktop/default.nix
    ../../modules/vm/default.nix
  ];

  networking.hostName = "New-H0Ryzen";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Do not change this value after the initial install. It pins the
  # compatibility baseline for stateful NixOS features.
  system.stateVersion = "24.11";
}

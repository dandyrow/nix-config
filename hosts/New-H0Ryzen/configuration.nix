{ inputs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/common/default.nix
    ../../modules/desktop/default.nix
    ../../modules/vm/default.nix
  ];

  networking.hostName = "New-H0Ryzen";

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    # Timeout of 0 boots immediately. Hold Space during boot to access the menu.
    timeout = 0;
    efi.canTouchEfiVariables = true;
  };

  # Do not change this value after the initial install. It pins the
  # compatibility baseline for stateful NixOS features.
  system.stateVersion = "24.11";
}

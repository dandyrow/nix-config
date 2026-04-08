{ inputs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/common/default.nix
    ../../modules/desktop/default.nix
    ../../modules/vm/default.nix
  ];

  networking.hostName = "New-H0Ryzen";

  # Tell the display stack to use the NVIDIA driver.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Kernel mode-setting is required for Wayland to work with NVIDIA.
    modesetting.enable = true;

    # Use the proprietary driver. Set to true to use the open-source kernel
    # modules instead — only supported on Turing (RTX 20xx) and newer GPUs.
    open = false;

    # Install nvidia-settings for tweaking GPU options from the desktop.
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

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

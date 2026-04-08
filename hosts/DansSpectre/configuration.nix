{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/common/default.nix
    ../../modules/desktop/default.nix
  ];

  networking.hostName = "DansSpectre";

  hardware.cpu.intel.updateMicrocode = true;

  # Kaby Lake G requires redistributable firmware blobs for the AMD GPU.
  hardware.enableRedistributableFirmware = true;

  # Tell the display stack to use the AMD driver.
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.bluetooth = {
    enable = true;
    # Power on the adapter at boot so it is ready without manual intervention.
    powerOnBoot = true;
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

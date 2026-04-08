{ pkgs, config, ... }: {
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  services.desktopManager.gnome.enable = true;

  programs.xwayland.enable = true;

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

  # Hardware graphics acceleration (required for Wayland compositing).
  hardware.graphics.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # needed for 32-bit apps (e.g. Steam, Wine)
    pulse.enable = true;
  };

  # RTKit gives PipeWire real-time scheduling priority.
  security.rtkit.enable = true;

  services.printing = {
    enable = true;
    # Allow any user to manage printers without a password prompt.
    allowFrom = [ "localhost" ];
  };

  # Passwordless print queue management for users.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("com.redhat.cups") == 0 && subject.isInGroup("users")) {
        return polkit.Result.YES;
      }
    });
  '';

  networking.networkmanager.enable = true;
}

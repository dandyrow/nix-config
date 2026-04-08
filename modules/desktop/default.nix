{ pkgs, ... }: {
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  services.desktopManager.gnome.enable = true;

  programs.xwayland.enable = true;

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

  programs.steam.enable = true;
}

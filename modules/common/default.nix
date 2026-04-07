{ pkgs, ... }: {
  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_IE.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  hardware.cpu.amd.updateMicrocode = true;

  security.sudo.enable = false;

  security.doas = {
    enable = true;
    extraRules = [{
      groups   = [ "wheel" ];
      keepEnv  = true;
      persist  = true;
    }];
  };

  programs.gnupg.agent.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.dandyrow = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
}

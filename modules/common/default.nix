{ pkgs, ... }: {
  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_IE.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    enable           = true;
    enableCompletion = true;
    enableLsColors   = true;

    autosuggestions.enable    = true;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

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

  services.xserver.xkb.layout = "gb";

  console.keyMap = "uk";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.dandyrow = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    # Hash is injected at install time via nixos-anywhere --extra-files.
    # Never committed in plaintext — see README for the install procedure.
    hashedPasswordFile = "/etc/secrets/dandyrow-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0aD5czQSOcwjOH2snxFNmoG3BWd/F6fX1ngZcIo+j3 work-machine"
    ];
  };
}

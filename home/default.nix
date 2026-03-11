# Shared Home Manager configuration — imported by every machine (NixOS and
# standalone alike). Imports the dotfiles module which wires up live symlinks
# to the raw config files and auto-clones the dotfiles repo if absent.
{ inputs, pkgs, ... }: {
  imports = [ inputs.dotfiles.homeManagerModules.default ];

  home.username      = "dandyrow";
  home.homeDirectory = "/home/dandyrow";

  # This value determines the Home Manager release compatibility baseline.
  # Do not change it arbitrarily — only update it when Home Manager release
  # notes explicitly instruct you to.
  home.stateVersion = "24.11";

  # Let Home Manager manage itself when used in standalone mode.
  programs.home-manager.enable = true;

  # Enable flakes and the new-style nix CLI on non-NixOS machines.
  # Writes ~/.config/nix/nix.conf so subsequent nix commands work without flags.
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Packages whose config lives in the dotfiles repo.
  home.packages = with pkgs; [
    bat
    btop
    eza
    fastfetch
    git
    neovim
    starship
    tmux
    yazi
    zsh
  ];
}

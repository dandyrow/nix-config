# Shared Home Manager configuration — imported by every machine (NixOS and
# standalone alike). Imports the dotfiles module which wires up live symlinks
# to the raw config files and auto-clones the dotfiles repo if absent.
{ inputs, pkgs, lib, isNixOS ? false, ... }: {
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

  # On non-NixOS machines configure the system to use nix-installed zsh.
  # Runs once per machine and all three operations are idempotent.
  # On NixOS this is skipped as NixOS handles it via programs.zsh and
  # users.users.<name>.shell in the system configuration.
  home.activation.setupSystem = lib.mkIf (!isNixOS)
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! grep -qF 'ZDOTDIR' /etc/zshenv 2>/dev/null; then
        printf 'export ZDOTDIR="%s/.config/zsh"\n' "$HOME" \
          | sudo tee -a /etc/zshenv >/dev/null
      fi

      ZSH="$HOME/.nix-profile/bin/zsh"
      if ! grep -qF "$ZSH" /etc/shells 2>/dev/null; then
        echo "$ZSH" | sudo tee -a /etc/shells >/dev/null
      fi

      if [ "$SHELL" != "$ZSH" ]; then
        chsh -s "$ZSH"
      fi
    '');
}

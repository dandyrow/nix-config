# Shared Home Manager configuration — imported by every machine (NixOS and
# standalone alike). Imports the dotfiles module which wires up live symlinks
# to the raw config files and auto-clones the dotfiles repo if absent.
{ inputs, pkgs, lib, isNixOS ? false, isWSL ? false, ... }: {
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

  # Prepend ~/.nix-profile/bin to PATH so nix-installed tools are found after
  # bootstrap. This is injected into hm-session-vars.sh which .zshrc sources.
  home.sessionPath = [ "$HOME/.nix-profile/bin" ];

  # Packages whose config lives in the dotfiles repo.
  home.packages = with pkgs; [
    bat
    btop
    eza
    fastfetch
    fd
    fzf
    gcc
    gh
    go
    git
    gnumake
    neovim
    nodejs
    (python3.withPackages (ps: [ ps.pip ]))
    ripgrep
    starship
    tmux
    tree-sitter
    unzip
    yazi
    zoxide
    zsh
  ] ++ lib.optionals isWSL [
    wl-clipboard
  ];

  # On non-NixOS machines configure the system to use nix-installed zsh.
  # Runs once per machine and all three operations are idempotent.
  # On NixOS this is skipped as NixOS handles it via programs.zsh and
  # users.users.<name>.shell in the system configuration.
  home.activation.setupSystem = lib.mkIf (!isNixOS)
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v sudo >/dev/null 2>&1; then
        _priv="sudo"
      elif command -v doas >/dev/null 2>&1; then
        _priv="doas"
      else
        echo "Warning: no sudo or doas found, skipping system modifications"
        _priv=""
      fi

      ZSH="$HOME/.nix-profile/bin/zsh"

      if [ -n "$_priv" ]; then
        if ! grep -qF 'ZDOTDIR' /etc/zshenv 2>/dev/null; then
          printf 'export ZDOTDIR="%s/.config/zsh"\n' "$HOME" \
            | $_priv tee -a /etc/zshenv >/dev/null
        fi

        if ! grep -qF "$ZSH" /etc/shells 2>/dev/null; then
          echo "$ZSH" | $_priv tee -a /etc/shells >/dev/null
        fi
      fi

      if [ "$SHELL" != "$ZSH" ]; then
        chsh -s "$ZSH"
      fi
    '');
}

# Desktop-specific Home Manager configuration.
# Import alongside home/default.nix for desktop and laptop machines.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    kitty
  ];
}

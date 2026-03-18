{
  description = "NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager module to create live symlinks to config files within repo.
    dotfiles.url = "github:dandyrow/dotfiles";
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};

    # Helper to reduce boilerplate for standalone HM configurations.
    # isNixOS: set to true when embedding HM inside a NixOS configuration so
    # that activation scripts which modify system files (e.g. /etc/zshenv,
    # /etc/shells) are skipped as NixOS manages those itself.
    # isWSL: set to true for machines running under WSL to include
    # WSL-specific packages (e.g. wl-clipboard for Windows clipboard integration).
    mkHome = { modules, isNixOS ? false, isWSL ? false }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs isNixOS isWSL; };
        inherit modules;
      };
  in
  {
    # -------------------------------------------------------------------------
    # NixOS system configurations
    # Add one entry per NixOS machine as you set them up, e.g.:
    #
    #   nixosConfigurations.my-desktop = nixpkgs.lib.nixosSystem {
    #     inherit system;
    #     specialArgs = { inherit inputs; };
    #     modules = [
    #       ./hosts/my-desktop/configuration.nix
    #       home-manager.nixosModules.home-manager
    #       {
    #         home-manager.useGlobalPkgs = true;
    #         home-manager.useUserPackages = true;
    #         home-manager.extraSpecialArgs = { inherit inputs; };
    #         home-manager.users.dandyrow = import ./home/default.nix;
    #       }
    #     ];
    #   };
    # -------------------------------------------------------------------------
    nixosConfigurations = {};

    # -------------------------------------------------------------------------
    # Standalone Home Manager configurations (non-NixOS machines)
    #
    # Bootstrap on any new machine with Nix installed (run once):
    #   NIX_CONFIG="experimental-features = nix-command flakes" \
    #     nix run home-manager/release-24.11 -- switch \
    #     --flake github:dandyrow/nix-config#dandyrow --refresh
    #
    # On subsequent runs (after experimental-features is in nix.conf):
    #   home-manager switch --flake github:dandyrow/nix-config#dandyrow --refresh
    #
    # Machine-specific configs import default.nix plus a host module.
    # Switch with: home-manager switch --flake .#dandyrow@<hostname>
    # -------------------------------------------------------------------------
    homeConfigurations = {
      "dandyrow" = mkHome { modules = [ ./home/default.nix ]; isWSL = true; };
    };
  };
}

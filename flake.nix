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
    mkHome = modules: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
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
    # Bootstrap on any new machine (run once):
    #   nix --extra-experimental-features "nix-command flakes" \
    #     run home-manager/release-24.11 -- switch \
    #     --flake github:dandyrow/nix-config#dandyrow
    #
    # On subsequent runs (after experimental-features is in nix.conf):
    #   home-manager switch --flake github:dandyrow/nix-config#dandyrow
    #
    # Machine-specific configs import default.nix plus a host module.
    # Switch with: home-manager switch --flake .#dandyrow@<hostname>
    # -------------------------------------------------------------------------
    homeConfigurations = {
      "dandyrow" = mkHome [ ./home/default.nix ];
    };
  };
}

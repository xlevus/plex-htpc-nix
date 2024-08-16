{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }
  };

  outputs = { nixpkgs, disko, nixos-generators, home-manager, nix-flatpak, ... }:
  {
    nixosConfigurations = {

     "htpc-test.home.xlevus.net" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          ./htpc/configuration.nix
        ];
      };

    };

    packages.x86_64-linux = {
      htpc-1 = nixos-generators.nixosGenerate {
        system = "armv7l-linux";
        modules = [
          ./common/users.nix
        ];
      };
    };
  };
}
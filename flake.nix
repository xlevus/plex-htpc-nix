{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, home-manager, nix-flatpak, nixos-hardware, ... }:
  let
    eachSystem = f:
      nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"] (system:
        f {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );
  in
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

      # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4
      "htpc-1" = nixpkgs.lib.nixosSystem {
        modules = [
          # TODO: move this to a configuration.nix file
          ({ pkgs, ... }: {
            imports = [
              home-manager.nixosModules.home-manager
              nixos-hardware.nixosModules.raspberry-pi-4
              ./htpc/user.nix
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ];

            nixpkgs.hostPlatform = "aarch64-linux";

            # Fix missing modules
            # https://github.com/NixOS/nixpkgs/issues/154163
            nixpkgs.overlays = [
              (final: super: {
                makeModulesClosure = x:
                  super.makeModulesClosure (x // { allowMissing = true; });
              })
            ];

            hardware = {
              raspberry-pi."4".apply-overlays-dtmerge.enable = true;
              deviceTree = {
                enable = true;
                filter = "*rpi-4-*.dtb";
              };
            };

            console.enable = false;

            environment.systemPackages = with pkgs; [
              libraspberrypi
              raspberrypi-eeprom
            ];

            system.stateVersion = "24.05";
          })
        ];
      };

    };

    packages = eachSystem ({ system, ... }: {
      htpc-1-sdImage = (self.nixosConfigurations.htpc-1.extendModules {
        # Configure cross-compilation
        modules = [ { nixpkgs.buildPlatform.system = system; } ];
        # Expose the sdImage brought in by the sd-image-aarch64.nix profile
      }).config.system.build.sdImage;
    });
  };
}

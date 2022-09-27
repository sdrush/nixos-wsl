{
  description = "NixOS WSL";

  inputs = {
    # Nix Package Sets
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Nix Home-Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    {

      nixosModules.wsl = {
        imports = [
          ./modules/build-tarball.nix
          ./modules/wsl-distro.nix
          ./modules/docker-desktop.nix
          ./modules/installer.nix
        ];
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };

    } //
    flake-utils.lib.eachSystem
      (with flake-utils.lib.system; [ "x86_64-linux" "aarch64-linux" ])
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          checks.check-format = pkgs.runCommand "check-format"
            {
              buildInputs = with pkgs; [ nixpkgs-fmt ];
            } ''
            nixpkgs-fmt --check ${./.}
            mkdir $out # success
          '';

          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ nixpkgs-fmt ];
          };
        }
      );
}

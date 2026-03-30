{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    finix.url = "github:finix-community/finix";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    ufetch-finix = {
      url = "github:voxelmesh/ufetch-finix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, finix, nixpkgs, nix-cachyos-kernel, ufetch-finix, ... }:
  let
    system = "x86_64-linux";
	lib = nixpkgs.lib;
    os = lib.evalModules {
      specialArgs = { inherit system inputs; };
      modules = [
        ./overlays.nix
        {
          overlays = [
            (final: prev: import ./pkgs { inherit final prev; })
          	ufetch-finix.overlays.default
          ];
        }
        ./base-configuration.nix
        ./host-configuration.nix
      ] ++ lib.attrValues finix.nixosModules;
    };
  in
  {
    packages.${system}.default = os.config.system.topLevel;
  };
}

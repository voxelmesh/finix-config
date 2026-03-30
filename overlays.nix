{ config, inputs, lib, system, ... }:
{
  options.overlays = lib.mkOption {
    type = lib.types.listOf lib.types.raw;
    default = [];	
  };

  config.nixpkgs.pkgs = lib.mkForce (import inputs.nixpkgs {
  	inherit system;
  	config.allowUnfree = true;
  	overlays = config.overlays;
  });
}

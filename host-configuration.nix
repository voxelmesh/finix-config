# The host specific configuration unique to the system

{ config, pkgs, lib, ... }:
{
  imports = [
    ./profiles/graphical.nix
    ./modules/hardware/video/nvidia.nix
  ];

  profile.sessionCommands = ''
    ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --mode 1920x1080@169.996994
  '';

  hardware.console.keyMap = "us";
  services.xserver.xkb.layout = config.hardware.console.keyMap;

  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };
  fileSystems."/home" = {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };
  fileSystems."/nix" = {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };
  fileSystems."/.snapshots" = {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "compress=zstd" ];
  };
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    neededForBoot = true;
  };
}

{ lib, pkgs, config, ... }:
let
  nvidiaPkg = config.hardware.nvidia.package;
in
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    enable = true;
    open = lib.versionAtLeast nvidiaPkg.version "595";
    powerManagement.enable = lib.versionAtLeast nvidiaPkg.version "430.09";
    powerManagement.finegrained = false;
  };

  # does not support finegrained power management
  finit.tasks.nvidiaSetup = lib.mkIf (!config.services.udev.enable) {
    runlevels = "S";
    command = pkgs.writeShellScript "nvidia-setup-script" ''
      until [ -f /proc/driver/nvidia/version ]; do sleep 0.1; done
      
      mknod -m 666 /dev/nvidiactl c 195 255
      mknod -m 666 /dev/nvidia-modeset c 195 254

      for i in $(cat /proc/driver/nvidia/gpus/*/information | grep Minor | cut -d " " -f 4); do
        mknod -m 666 /dev/nvidia$i c 195 $i
      done

        until grep -q nvidia-uvm /proc/devices; do sleep 0.1; done

        minor=$(grep nvidia-uvm /proc/devices | cut -d " " -f 1)
        mknod -m 666 /dev/nvidia-uvm c $minor 0
        mknod -m 666 /dev/nvidia-uvm-tools c $minor 1
    '';
  };
}
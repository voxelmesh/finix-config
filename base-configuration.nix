# The base configuration - shared between all hosts
{ lib, pkgs, config, system, ... }:
let
  meta = {
    user = "voxl";
  };
in
{
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  overlays = [(final: prev: {
    xdg-desktop-portal = prev.xdg-desktop-portal.override { enableSystemd = false; };
    xwayland-satellite = prev.xwayland-satellite.override { withSystemd = false; };
  })];

  services = {
    dbus.enable = true;
    dhcpcd.enable = true;
    mdevd.enable = true;
    sysklogd.enable = true; # needed by nix-daemon
    nix-daemon = {
      enable = true;
      settings.extra-experimental-features = [ "flakes" "nix-command" "pipe-operators" ];
    };
  };

  specialisation.udev = {
  	services.mdevd.enable = lib.mkForce false;
  	services.udev.enable = lib.mkForce true;
  };

  services.udev.packages = [ config.services.udev.package ];

  services.mdevd.hotplugRules = lib.mkMerge [
    (lib.mkAfter ''
      SUBSYSTEM=input;.* root:input 660
      SUBSYSTEM=sound;.* root:audio 660
    '')

    ''
      grsec       root:root 660
      kmem        root:root 640
      mem         root:root 640
      port        root:root 640
      console     root:tty  600 @chmod 600 $MDEV

      card[0-9]+   root:video  660 =dri/
      render[0-9]+ root:render 660 =dri/

      # alsa sound devices and audio stuff
      pcm.*       root:audio 0660 =snd/
      control.*   root:audio 0660 =snd/
      midi.*      root:audio 0660 =snd/
      seq         root:audio 0660 =snd/
      timer       root:audio 0660 =snd/

      adsp        root:audio 0660 >sound/
      audio       root:audio 0660 >sound/
      dsp         root:audio 0660 >sound/
      mixer       root:audio 0660 >sound/
      sequencer.* root:audio 0660 >sound/

      event[0-9]+ root:input 660 =input/
      mice        root:input 660 =input/
      mouse[0-9]+ root:input 660 =input/

      rfkill      root:${config.services.seatd.group} 660
    ''
  ];

  boot = {
    loader.efi.canTouchEfiVariables = true;
    #kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts;
    kernelPackages = pkgs.linuxPackages_6_12;
  };

  programs = {
    pmount.enable = true;
    zzz.enable = true;
    doas.enable = true;
    bash.enable = true;
    fish.enable = true;
    shadow.enable = true;
    gnome-keyring.enable = true;
    limine = {
      enable = true;
      settings.editor_enabled = true;
    };
  };

  users = {
    groups.render = {};
    users.${meta.user} = {
      isNormalUser = true;
      extraGroups = [
        config.services.seatd.group
        "video"
        "render"
        "audio"
        "input"
        "wheel"
      ];
      shell = pkgs.fish;
    };
  };

  networking = {
    hostName = "finix";
  };

  finit = {
    runlevel = 3;
  };

  environment.systemPackages = [
    pkgs.micro
    pkgs.neovim
    pkgs.git
    pkgs.wget
    pkgs.aria2
    pkgs.pciutils
    pkgs.usbutils
    pkgs.iproute2
    pkgs.iputils
    pkgs.nettools
    pkgs.perl
    pkgs.strace
    pkgs.unrar
    pkgs.unzip
    pkgs.util-linux
    pkgs.pipewire
    pkgs.wireplumber
    pkgs.flatpak
    pkgs.ufetch

    (pkgs.writeShellScriptBin "finix-rebuild" ''
      #!/bin/sh
      set -e
      DIR="/etc/finix"
      nix build --profile /nix/var/nix/profiles/system "$DIR#" --impure --extra-experimental-features 'nix-command flakes pipe-operators'
      /nix/var/nix/profiles/system/bin/switch-to-configuration switch
    '')
  ];
}

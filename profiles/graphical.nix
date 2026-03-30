# Profile for everything graphical

{ config, pkgs, lib, ... }:
{
  options.profile = {
    sessionCommands = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = ''
        updateDisplay () {
          ''${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --mode 1920x1080@170
        }
        updateDisplay
        while true; do
          updateDisplay 2>/dev/null
          sleep 5
        done &
      '';
    };
  };

  config = {
    fonts = {
      fontconfig.enable = true;
      packages = [
        pkgs.fira-code
        pkgs.fira-code-symbols
        pkgs.font-awesome
        pkgs.liberation_ttf
        pkgs.noto-fonts
        pkgs.noto-fonts-color-emoji
      ];
      enableDefaultPackages = true;
    };
    
    services = {
      seatd.enable = true;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    xdg.portal.portals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];

    environment.systemPackages = [
      pkgs.wl-clipboard
      pkgs.xdg-utils
      pkgs.librewolf
      pkgs.steam
      pkgs.steam.run
      pkgs.gamemode
      pkgs.prismlauncher
      pkgs.thunar
      pkgs.file-roller
      pkgs.imv
      pkgs.slurp
      pkgs.grim
      pkgs.foot
      pkgs.wmenu
      pkgs.wlr-randr
      pkgs.equibop
      pkgs.dwl

      (pkgs.writeShellScriptBin "start-session" ''
        set -e
        trap 'kill $(jobs -p) 2>/dev/null' EXIT

        if [ -n "$WAYLAND_DISPLAY" ]; then
          echo "wayland already running" >&2
          exit 1
        fi
 
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.dwl}/bin/dwl &
        DWL_PID=$!

        ${pkgs.pipewire}/bin/pipewire &
        ${pkgs.pipewire}/bin/pipewire-pulse &
        ${pkgs.wireplumber}/bin/wireplumber &

        timeout 4 sh -c 'until ${pkgs.wlr-randr}/bin/wlr-randr 2>/dev/null; do sleep 0.5; done'
        
        ${config.profile.sessionCommands}

        wait $DWL_PID
      '')
    ];

    programs.xwayland-satellite.enable = true;
  };
}

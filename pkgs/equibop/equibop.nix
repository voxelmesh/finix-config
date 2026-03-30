{
  stdenv,
  fetchurl,
  makeDesktopItem,
  makeWrapper,
  autoPatchelfHook,
  lib,
  libglvnd,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  pulseaudio,
  udev,
  wayland,
  ...
}:
let
  pname = "equibop";
  version = "3.1.9";
  desktop = makeDesktopItem {
    name = pname;
    desktopName = "Equibop";
    exec = "${pname} %U";
    icon = pname;
    categories = [ "Network" "InstantMessaging" ];
  };
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchurl {
    url = "https://github.com/Equicord/Equibop/releases/download/v${version}/equibop-${version}.tar.gz";
    sha256 = "sha256:17s61dn1md2bfkhvqd0nqkkzxhrszkxrxk77qh5wd1baz1m98i73";
  };
  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];
  buildInputs = [
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat
    gdk-pixbuf glib gtk3 libdrm libX11 libXcomposite libXdamage
    libXext libXfixes libXrandr libxcb libxkbcommon mesa nspr nss
    pango pipewire pulseaudio udev wayland libglvnd
    stdenv.cc.cc.lib
  ];
  installPhase = ''
    mkdir -p $out/opt/equibop $out/bin $out/share/applications
    cp -r . $out/opt/equibop/
    chmod -R u+w $out/opt/equibop
    cp ${desktop}/share/applications/* $out/share/applications/
    makeWrapper $out/opt/equibop/equibop $out/bin/equibop \
      --add-flags "--enable-features=WebRTCPipeWireCapturer" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd mesa pipewire udev pulseaudio stdenv.cc.cc.lib ]}" \
      --set GSETTINGS_SCHEMA_DIR "${gtk3}/share/gsettings-schemas/${gtk3.name}/glib-2.0/schemas" \
      --run '
        if [ -n "$WAYLAND_DISPLAY" ]; then
          export ELECTRON_OZONE_PLATFORM_HINT=wayland
        fi
      '
  '';

  # Tell autoPatchelf not to touch the bundled Electron libs
  autoPatchelfIgnoreMissingDeps = [ "libEGL.so" "libGLESv2.so" "libvulkan.so.1" ];

  # Prepend equibop's own lib dir so its bundled ANGLE EGL loads before system ones
  postFixup = ''
    patchelf --set-rpath "$out/opt/equibop:${lib.makeLibraryPath [ libglvnd mesa pipewire udev pulseaudio stdenv.cc.cc.lib ]}" $out/opt/equibop/equibop
  '';
}
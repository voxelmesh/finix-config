{ prev }:
(prev.libinput.overrideAttrs (o: {
  patches = (o.patches or []) ++ [ ./no-udev-dep.patch ];
}))
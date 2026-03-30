{ prev }:
(prev.pipewire.override {
  enableSystemd = false;
}).overrideAttrs (o: {
  patches = (o.patches or []) ++ [ ./no-udev-dep.patch ];
})

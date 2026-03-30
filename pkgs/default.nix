{ prev, ... }:
let
  callPackage = prev.callPackage;
in
{
  inherit prev;

  pipewire = callPackage ./pipewire {};
  dwl = callPackage ./dwl {};
  equibop = callPackage ./equibop {};
  libinput = callPackage ./libinput {};
}

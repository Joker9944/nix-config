{ mkMixinModule, ... }:
{ lib, pkgs, ... }:
mkMixinModule "vlc" {
  config =
    let
      package = pkgs.vlc;
    in
    {
      home.packages = lib.toList package;

      xdg.mimeApps.custom.apps.default = lib.mkOrder 20 [
        "${package}/share/applications/vlc.desktop"
      ];
    };
}

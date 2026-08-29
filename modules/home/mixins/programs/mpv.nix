{ mkMixinModule, ... }:
{ lib, config, ... }:
mkMixinModule "mpv" {
  programs.mpv = {
    enable = true;
  };

  xdg.mimeApps.custom.apps.default = lib.mkOrder 10 [
    "${config.programs.mpv.package}/share/applications/umpv.desktop" # cSpell:ignore umpv
  ];
}

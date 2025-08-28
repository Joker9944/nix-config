{ lib, pkgs, ... }:
let
  bin.firefox = lib.getExe pkgs.firefox;
in
{
  xdg.configFile."firefoxprofileswitcher/config.json".text = ''
    {"browser_binary": "${bin.firefox}"}
  '';
}

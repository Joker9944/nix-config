{pkgs, ...}:
with pkgs; let
  firefoxBin = "${firefox}/bin/firefox";
in {
  xdg.configFile."firefoxprofileswitcher/config.json".text = ''
    {"browser_binary": "${firefoxBin}"}
  '';
}

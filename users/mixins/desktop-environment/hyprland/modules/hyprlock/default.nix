{ mkDefaultHyprlandModule, ... }:
{ lib, pkgs-hyprland, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  config.programs.hyprlock = {
    enable = true;
    package = pkgs-hyprland.hyprlock;

    settings = {
      general = {
        hide_cursor = true;
      };

      auth.fingerprint = {
        enabled = lib.mkDefault false;
        ready_message = "Scan fingerprint to unlock";
        present_message = "Scanning...";
      };
    };
  };
}

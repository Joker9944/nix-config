/**
  * lock screen
*/
{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
in
utility.custom.mkHyprlandModule config {
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

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

      input-field = {
        fade_on_empty = false;

        placeholder_text = "Input password...";
        fail_text = "$PAMFAIL";
      };
    };
  };
}

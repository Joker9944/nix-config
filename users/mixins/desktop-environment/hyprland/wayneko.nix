{
  lib,
  config,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {

  programs.wayneko =
    let
      inherit (config.windowManager.hyprland.custom.style) scheme;
    in
    {
      enable = true;

      systemd = {
        enable = true;
        extraArgs = [
          "--layer"
          "overlay"
          "--background-colour"
          (lib.replaceString "#" "0x" scheme.accent.hex)
          "--outline-colour"
          (lib.replaceString "#" "0x" scheme.background.normal.hex)
        ];
      };
    };
}

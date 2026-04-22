{ mkHyprlandModule, ... }:
{ config, ... }:
mkHyprlandModule {
  programs.wayneko =
    let
      inherit (config.mixins.desktopEnvironment.hyprland.style) scheme;
    in
    {
      enable = true;

      systemd = {
        enable = true;
        extraArgs = [
          "--layer"
          "overlay"
          "--background-colour"
          "0x${scheme.accent.hex}"
          "--outline-colour"
          "0x${scheme.background.normal.hex}"
        ];
      };
    };
}

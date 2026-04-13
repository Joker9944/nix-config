{ mkHyprlandModule, ... }:
{ lib, config, ... }:
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
          (lib.replaceString "#" "0x" scheme.accent.hex)
          "--outline-colour"
          (lib.replaceString "#" "0x" scheme.background.normal.hex)
        ];
      };
    };
}

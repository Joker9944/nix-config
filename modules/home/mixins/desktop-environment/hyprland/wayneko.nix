{ mkHyprlandModule, ... }:
{ config, ... }:
mkHyprlandModule {
  programs.wayneko =
    let
      inherit (config.schemes) scheme;
    in
    {
      enable = true;

      systemd = {
        enable = true;
        extraArgs = [
          "--layer"
          "overlay"
          # empty input region, otherwise the overlay swallows clicks in the bottom 32px
          "--follow-pointer"
          "false"
          "--background-colour"
          "0x${scheme.accent.hex}"
          "--outline-colour"
          "0x${scheme.named.background.normal.hex}"
        ];
      };
    };
}

{
  lib,
  config,
  osConfig,
  pkgs-unstable,
  ...
}:
{
  options.mixins.programs.lutris =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "lutris config mixin";
    };

  config.programs.lutris =
    let
      cfg = config.mixins.programs.lutris;
    in
    lib.mkIf cfg.enable {
      enable = true;

      package = pkgs-unstable.lutris;
      extraPackages = with pkgs-unstable; [
        mangohud
        winetricks
        gamemode
        umu-launcher
      ];

      protonPackages = [ pkgs-unstable.proton-ge-bin ];

      steamPackage = osConfig.programs.steam.package;
    };
}

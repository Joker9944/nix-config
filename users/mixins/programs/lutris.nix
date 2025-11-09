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

      # WORKAROUND lutris package is currently borked on 25.05 but fixed on unstable, remove once patch is backported
      # https://github.com/NixOS/nixpkgs/issues/454995
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

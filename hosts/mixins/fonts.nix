{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.fonts =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "fonts config mixin";
    };

  config =
    let
      cfg = config.mixins.fonts;
    in
    lib.mkIf cfg.enable {

      fonts.packages = with pkgs; [
        lato
        roboto
        texlivePackages.opensans
        texlivePackages.nunito
      ];
    };
}

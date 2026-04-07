{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.services.printing =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "printing config mixin";
    };

  config =
    let
      cfg = config.mixins.services.printing;
    in
    lib.mkIf cfg.enable {
      services = {
        # Enable cups by default
        printing = {
          enable = lib.mkDefault true;
          drivers = [ pkgs.epson-escpr ];
        };
      };
    };
}

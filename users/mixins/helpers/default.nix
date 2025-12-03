{
  lib,
  config,
  custom,
  ...
}:
{
  imports = custom.lib.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  options.mixins.helpers =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "helper base mixin";
    };

  config.custom.command-collection =
    let
      cfg = config.mixins.helpers;
    in
    lib.mkIf cfg.enable {
      enable = true;

      name = "cc";
      help = "cli with a collection of common commands";
    };
}

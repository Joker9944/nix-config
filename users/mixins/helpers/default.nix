{ mkDefaultMixinModule, ... }:
{ lib, config, ... }:
let
  cfg = config.mixins.helpers;
in
mkDefaultMixinModule
  {
    dir = ./.;
    prefix = [ "helpers" ];
  }
  {
    options.mixins.helpers.enable = lib.mkEnableOption "helper base mixin";

    config.custom.command-collection = lib.mkIf cfg.enable {
      enable = true;

      name = "cc";
      help = "cli with a collection of common commands";
    };
  }

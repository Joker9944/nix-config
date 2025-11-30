{ lib, config, ... }:
{
  options.mixins.services.ollama =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "ollama config mixin";
    };

  config =
    let
      cfg = config.mixins.services.ollama;
    in
    lib.mkIf cfg.enable {
      services.ollama.enable = true;
    };
}

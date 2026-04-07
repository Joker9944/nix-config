{ lib, config, ... }:
{
  options.mixins.keymap =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "keymap config mixin";

      type = mkOption {
        type = types.enum [
          "de-us"
          "ch"
        ];
        default = "de-us";
      };
    };

  config =
    let
      cfg = config.mixins.keymap;
      combined = lib.splitString "-" cfg.type;
    in
    lib.mkIf cfg.enable {
      services.xserver.xkb = {
        layout = lib.elemAt combined 0;
        variant = lib.mkIf (lib.length combined > 1) (lib.elemAt combined 1);
      };

      console.useXkbConfig = true;
    };
}

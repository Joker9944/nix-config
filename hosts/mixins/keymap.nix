{ lib, config, ... }:
{
  options.mixins.keymap =
    let
      inherit (lib) mkOption types;
    in
    {
      type = mkOption {
        type = types.enum [
          "de-us"
          "ch"
        ];
        default = "de-us";
      };
    };

  config.services.xserver.xkb =
    let
      cfg = config.mixins.keymap;
      combined = lib.splitString "-" cfg.type;
    in
    {
      layout = lib.elemAt combined 0;
      variant = lib.mkIf (lib.length combined > 1) (lib.elemAt combined 1);
    };
}

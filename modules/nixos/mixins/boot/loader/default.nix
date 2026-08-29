{ mkDefaultMixinModule, ... }:
{ lib, config, ... }:
mkDefaultMixinModule
  {
    dir = ./.;
    prefix = [
      "boot"
      "loader"
    ];
  }
  {
    assertions = [
      {
        assertion = lib.count (l: l.enable) (lib.attrValues config.mixins.boot.loader) <= 1;
        message = "boot: enable at most one bootloader, got ${
          toString (lib.attrNames (lib.filterAttrs (_: l: l.enable) config.mixins.boot.loader))
        }";
      }
    ];
  }

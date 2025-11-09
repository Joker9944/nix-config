{ lib, config, ... }:
{
  options.mixins.programs.xournalpp =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "xournalpp config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.xournalpp;
    in
    lib.mkIf cfg.enable {
      programs = {
        xournalpp.enable = true;

        yazi.settings.open.prepend_rules = [
          {
            name = "*.xopp"; # cSpell:ignore xopp
            use = [
              "open"
              "reveal"
            ];
          }
        ];
      };

      xdg.mimeApps.custom.apps.associations.added = [
        "${config.programs.xournalpp.package}/share/applications/com.github.xournalpp.xournalpp.desktop"
      ];
    };
}

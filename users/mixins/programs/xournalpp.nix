{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "xournalpp" {
  programs = {
    xournalpp.enable = true;

    yazi.settings.open.prepend_rules = [
      {
        url = "*.xopp"; # cSpell:ignore xopp
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
}

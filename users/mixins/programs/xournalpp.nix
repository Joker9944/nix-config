{ mkMixinModule, ... }:
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
}

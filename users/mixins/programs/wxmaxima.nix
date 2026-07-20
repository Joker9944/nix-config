{ mkMixinModule, ... }:
mkMixinModule "wxmaxima" {
  programs = {
    wxmaxima.enable = true;

    yazi.settings.open.prepend_rules = [
      {
        url = "*.wxmx"; # cSpell:ignore wxmx
        use = [
          "open"
          "reveal"
        ];
      }
    ];
  };
}

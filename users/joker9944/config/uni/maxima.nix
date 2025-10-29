_: {
  programs = {
    wxmaxima.enable = true;

    yazi.settings.open.prepend_rules = [
      {
        name = "*.wxmx"; # cSpell:ignore wxmx
        use = [
          "open"
          "reveal"
        ];
      }
    ];
  };
}

{ mkMixinModule, ... }:
{ inputs, pkgs, ... }:
mkMixinModule "regreet" {
  imports = with inputs.nix-schemes.nixosModules; [
    scheme
    regreet
  ];

  programs.regreet = {
    enable = true;

    font = {
      name = "Inter";
      package = pkgs.inter;
      size = 10;
    };

    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };

    cursorTheme = {
      name = "Dracula-cursors";
      package = pkgs.dracula-theme;
    };

    settings.GTK.application_prefer_dark_theme = true;
  };

  schemes = {
    regreet = {
      enable = true;
      accent = "purple";
    };

    source.scheme = {
      system = "base16";
      slug = "uwunicorn"; # cSpell:words uwunicorn
    };

    transformers =
      let
        schemeTransformers = inputs.nix-schemes.lib.transformers;
      in
      [
        (schemeTransformers.interpolateBase24 { })
      ];
  };
}

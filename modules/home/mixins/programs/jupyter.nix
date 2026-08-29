{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "jupyter" {
  home.packages = [
    (pkgs.python3.withPackages (
      # cSpell:words numpy sympy seaborn ipywidgets ipympl
      ps: with ps; [
        jupyter
        numpy
        pandas
        sympy
        seaborn
        ipywidgets
        ipympl
      ]
    ))
  ];

  programs.yazi.settings.open.prepend_rules = [
    {
      url = "*.ipynb"; # cSpell:ignore ipynb
      use = [
        "open"
        "reveal"
      ];
    }
  ];
}

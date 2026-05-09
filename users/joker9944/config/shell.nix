{ pkgs, ... }:
{
  home = {
    packages = [ pkgs.moor ];

    sessionVariables.PAGER = "moor";

    shellAliases = {
      cls = "clear";
      mktar = "tar -czvf"; # cSpell:words mktar cSpell:ignore czvf
      untar = "tar -xvf"; # cSpell:words untar
      open = "xdg-open";
      less = "moor";
    };
  };
}

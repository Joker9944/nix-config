_:
{ pkgs, ... }:
{
  home = {
    packages = [ pkgs.moor ];

    sessionVariables.PAGER = "moor";

    shellAliases.less = "moor";

    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      cls = "clear";
      mktar = "tar -czvf"; # cSpell:words mktar cSpell:ignore czvf
      untar = "tar -xvf"; # cSpell:words untar
      open = "xdg-open";
      caffeine = "systemd-inhibit --no-ask-password --what=idle --who=user --why=caffeine sleep infinity";
    };
  };
}

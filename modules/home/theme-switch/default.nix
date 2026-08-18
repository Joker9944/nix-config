_:
{
  lib,
  pkgs,
  options,
  ...
}:
let
  # Every entry costs one extra full home-manager eval + build per rebuild; the base
  # configuration already carries the profile default theme.
  switchable = [
    "dracula"
    "uwunicorn"
  ];
in
{
  # The osConfig mirror assigns the whole `mixins.theme` map at normal priority, so
  # every declared theme's `enable` must be forced, not just the selected one.
  specialisation = lib.genAttrs switchable (name: {
    configuration.mixins.theme = lib.genAttrs (lib.attrNames options.mixins.theme) (theme: {
      enable = lib.mkForce (theme == name);
    });
  });

  home.packages = [
    (pkgs.writeShellApplication {
      name = "theme-switch";
      text = lib.readFile ./files/theme-switch.sh;
      runtimeInputs = with pkgs; [
        home-manager
        coreutils
        gawk
      ];
    })
  ];
}

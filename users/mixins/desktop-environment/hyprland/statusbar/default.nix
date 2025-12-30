{ custom, ... }:
{
  imports = custom.lib.ls {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config.programs = {
    waybar.enable = false;
    ashell.enable = false;
    yab.enable = true;
  };
}

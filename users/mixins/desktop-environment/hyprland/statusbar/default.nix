{ custom, ... }:
{
  imports = custom.lib.ls {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config.programs = {
    waybar.enable = true;
    ashell.enable = false;
  };
}

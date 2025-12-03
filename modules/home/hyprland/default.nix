{ lib, custom, ... }:
{
  imports = custom.lib.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  options.windowManager.hyprland.custom = with lib; {
    enable = mkEnableOption "Hyprland customization config";
  };
}

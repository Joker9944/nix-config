{ lib, custom, ... }:
{
  imports = custom.lib.ls {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  options.windowManager.hyprland.custom = with lib; {
    enable = mkEnableOption "Hyprland customization config";
  };
}

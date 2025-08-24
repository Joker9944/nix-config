{ lib, ... }:
{
  imports = [ ./hyprland ];

  options.windowManager.hyprland.custom = with lib; {
    enable = mkEnableOption "Hyprland customization config";
  };
}

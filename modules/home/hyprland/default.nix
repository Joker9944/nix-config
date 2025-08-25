{ lib, utility, ... }:
{
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  options.windowManager.hyprland.custom = with lib; {
    enable = mkEnableOption "Hyprland customization config";
  };
}

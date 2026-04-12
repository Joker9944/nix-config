{ lib, custom, ... }:
custom.lib.mkDefaultModule { dir = ./.; } {
  options.windowManager.hyprland.custom =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Hyprland customization config";
    };
}

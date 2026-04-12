{ flake }:
{ lib, ... }:
{
  imports =
    lib.pipe
      {
        dir = ./.;
        exclude = [ ./default.nix ];
      }
      [
        flake.lib.ls
        (lib.map (path: lib.modules.importApply path { inherit flake; }))
      ];

  options.windowManager.hyprland.custom =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Hyprland customization config";
    };
}

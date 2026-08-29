{ flake, ... }@moduleArgs:
{
  lib,
  config,
  ...
}:
let
  args = lib.fix (self: {
    mkHyprlandModule = flake.lib.modules.mkConditionalModule (
      lib.mkIf config.mixins.desktopEnvironment.hyprland.enable
    );

    mkDefaultHyprlandModule =
      fnArgs: module:
      flake.lib.modules.mkDefaultModule (lib.recursiveUpdate fnArgs { args = moduleArgs // self; }) (
        self.mkHyprlandModule module
      );
  });
in
args.mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Hyprland desktop environment config mixin";
    };
}

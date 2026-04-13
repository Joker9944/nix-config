{
  lib,
  config,
  custom,
  ...
}:
let
  functions = lib.fix (self: {
    mkHyprlandModule = custom.lib.mkConditionalModule (
      lib.mkIf config.mixins.desktopEnvironment.hyprland.enable
    );

    mkDefaultHyprlandModule =
      fnArgs: module:
      custom.lib.mkDefaultModule (lib.recursiveUpdate fnArgs { args = self; }) (
        self.mkHyprlandModule module
      );
  });
in
functions.mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Hyprland desktop environment config mixin";
    };
}

{ inputs, mkHyprlandModule, ... }:
{ config, osConfig, ... }:
mkHyprlandModule {
  imports = [ inputs.yas.homeModules.default ];

  programs.yas = {
    systemd.enable = config.programs.yas.enable;
    config.battery = osConfig.mixins.hardware.battery.enable;
  };
}

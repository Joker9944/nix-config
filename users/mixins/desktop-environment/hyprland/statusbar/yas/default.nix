{ mkHyprlandModule, ... }:
{ inputs, config, ... }:
mkHyprlandModule {
  imports = [ inputs.yas.homeModules.default ];

  programs.yas.systemd.enable = config.programs.yas.enable;
}

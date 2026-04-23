{ mkHyprlandModule, ... }:
{ inputs, config, ... }:
mkHyprlandModule {
  imports = [ inputs.yab.homeModules.default ];

  programs.yab.systemd.enable = config.programs.yab.enable;
}

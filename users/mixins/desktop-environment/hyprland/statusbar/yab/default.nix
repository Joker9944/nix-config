{ inputs, config, ... }:
{
  imports = [ inputs.yab.homeManagerModules.default ];

  programs.yab.systemd.enable = config.programs.yab.enable;
}

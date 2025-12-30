{ inputs, ... }:
{
  imports = [ inputs.yab.homeManagerModules.default ];

  programs.yab.systemd.enable = true;
}

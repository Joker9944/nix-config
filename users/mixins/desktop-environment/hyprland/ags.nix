{ inputs, pkgs, ... }:
{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = false;

    systemd.enable = true;

    configDir = "${pkgs.custom-shell}/share";
  };
}

{ mkMixinModule, ... }:
{ lib, config, ... }:
mkMixinModule "nh" {
  programs.nh = {
    enable = true;
    flake = lib.mkIf (
      config.xdg.userDirs.enable && config.xdg.userDirs.projects != null
    ) "${config.xdg.userDirs.projects}/nix-config";
  };
}

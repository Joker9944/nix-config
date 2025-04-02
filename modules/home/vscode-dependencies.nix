{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.vscode;
in {
  home.packages = with pkgs;
    lib.mkIf cfg.enable [
      sops
      kubectl
    ];
}

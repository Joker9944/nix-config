{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.bash =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "bash config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.bash;
    in
    lib.mkIf cfg.enable {
      programs.bash = {
        enable = true;

        enableCompletion = true;

        initExtra = ''
          nix-search() {
            nix-instantiate --eval-only --expr "(import <nixpkgs> {}).$1.outPath" | cut -d '"' -f 2
          }

          ${lib.getExe pkgs.fastfetch}
        '';

        shellAliases = {
          ls = "ls --color=auto --human-readable";
          ll = "ls --color=auto --human-readable -l --group-directories-first";
          la = "ls --color=auto --human-readable -l --all --group-directories-first";
          grep = "grep --color=auto";
          ".." = "cd ..";
          "..." = "cd ../..";
          cls = "clear";
          mktar = "tar -czvf"; # cSpell:words mktar cSpell:ignore czvf
          untar = "tar -xvf"; # cSpell:words untar
          open = "xdg-open";
        };
      };
    };
}

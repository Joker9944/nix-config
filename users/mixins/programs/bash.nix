{ lib, config, ... }:
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

        shellAliases = {
          ls = "ls --color=auto --human-readable";
          ll = "ls --color=auto --human-readable -l --group-directories-first";
          la = "ls --color=auto --human-readable -l --group-directories-first --all";
          grep = "grep --color=auto";
          ".." = "cd ..";
          "..." = "cd ../..";
        };
      };
    };
}

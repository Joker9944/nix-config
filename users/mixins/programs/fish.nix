{ lib, config, ... }:
{
  options.mixins.programs.fish =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "fish config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.fish;
    in
    lib.mkIf cfg.enable {
      programs = {
        bash.initExtra = lib.mkAfter ''
          # drop into fish shell
          if grep -qv 'fish' /proc/$PPID/comm && [[ ''${SHLVL} == [1,2] ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION='''
            exec fish $LOGIN_OPTION
          fi
        '';

        fish.enable = true;
      };
    };
}

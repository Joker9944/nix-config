{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "fish" {
  programs = {
    bash = {
      enable = true;
      initExtra = lib.mkAfter ''
        # drop into fish shell
        if grep -qv 'fish' /proc/$PPID/comm && [[ ''${SHLVL} == [1,2] ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION='''
          exec fish $LOGIN_OPTION
        fi
      '';
    };

    fish = {
      enable = true;
      preferAbbrs = true;
      functions.fish_greeting = "";
    };
  };
}

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

        fish = {
          enable = true;

          functions = {
            cls = {
              description = "alias cls=clear";
              wraps = "clear";
              body = "clear $argv";
            };

            open = {
              description = "alias open=xdg-open";
              wraps = "xdg-open";
              body = "xdg-open $argv";
            };

            less = {
              description = "alias less=moor";
              wraps = "moor";
              body = "moor $argv";
            };

            mktar = {
              # cSpell:words mktar cSpell:ignore czvf
              description = "alias mktar=tar -czvf";
              wraps = "tar";
              body = "tar -czvf $argv";
            };

            untar = {
              # cSpell:words untar
              description = "alias untar=tar -xvf";
              wraps = "tar";
              body = "tar -xvf $argv";
            };

            prompt_login = {
              description = "vendored and adjusted from embedded";
              body = ''
                if not set -q __fish_machine
                  set -g __fish_machine
                  set -l debian_chroot $debian_chroot

                  if test -r /etc/debian_chroot
                    set debian_chroot (cat /etc/debian_chroot)
                  end

                  if set -q debian_chroot[1]
                    and test -n "$debian_chroot"
                    set -g __fish_machine "(chroot:$debian_chroot)"
                  end
                end

                # Prepend the chroot environment if present
                if set -q __fish_machine[1]
                  echo -n -s (set_color yellow) "$__fish_machine" (set_color normal) ' '
                end

                # If we're running via SSH, change the host color.
                set -l color_host $fish_color_host
                if set -q SSH_TTY; and set -q fish_color_host_remote
                  set color_host $fish_color_host_remote
                end

                if test -n "$IN_NIX_SHELL"
                  echo -n -s (set_color $color_host) "<nix-shell>" (set_color normal)
                else
                  echo -n -s (set_color $fish_color_user) "$USER" (set_color normal) @ (set_color $color_host) (prompt_hostname) (set_color normal)
                end
              '';
            };
          };
        };
      };
    };
}

{ config, lib, pkgs, ... }:

with pkgs; let
  oidcAgentBin = "${ oidc-agent }/bin/oidc-agent";
  shBin = "${ bashInteractive }/bin/sh";
  echoBin = "${ coreutils }/bin/echo";
  rmBin = "${ coreutils }/bin/rm";
in {
  options.services.oidc-agent = with lib; {

    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable oidc-client.
      '';
    };

  };

  config = lib.mkIf config.services.oidc-agent.enable {
    home.packages = with pkgs; [ oidc-agent ];

    systemd.user.services.oidc-agent = {

      Unit = {
        Description = "OIDC Agent Service - Manage OpenID Connect tokens";
        Documentation = "https://indigo-dc.gitbook.io/oidc-agent";
      };

      Service = {
        Type = "exec";
        ExecStart = "${ oidcAgentBin } --console --quiet --log-stderr --socket-path \"%t/oidc-agent/oidc-agent.socket\" --pid-file \"%t/oidc-agent/oidc-agent.pid\"";
        ExecStartPost = [
          "${shBin} -c '${ echoBin } \"OIDC_SOCK = %t/oidc-agent/oidc-agent.socket\" >> \"%t/oidc-agent/oidc-agent.env\"'"
          "${shBin} -c '${ echoBin } \"OIDCD_PID = $MAINPID\" >> \"%t/oidc-agent/oidc-agent.env\"'"
        ];
        ExecStopPost = [
          "${ rmBin } \"%t/oidc-agent/oidc-agent.socket\""
          "${ rmBin } \"%t/oidc-agent/oidc-agent.pid\""
          "${ rmBin } \"%t/oidc-agent/oidc-agent.env\""
        ];
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

    };

    programs.bash.bashrcExtra = ''
      systemctl --user is-active --quiet oidc-agent.service && {
        export OIDC_SOCK="$XDG_RUNTIME_DIR/oidc-agent.socket"
        export OIDCD_PID="$(systemctl --user show --property MainPID --value oidc-agent.service)"
      } || {
        unset OIDC_SOCK
        unset OIDCD_PID
      }
    '';
  };
}

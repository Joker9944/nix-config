{ config, lib, pkgs, ... }:

let
  cfg = config.programs._1password;
in {

  options.programs._1password = with lib; {

    gitSigningKey = mkOption {
      type = lib.types.nullOr types.str;
      default = null;
      example = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";
      description = ''
        Public key used for git commit signing.
      '';
    };

    sshIdentityAgentHosts = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "*" ];
      description = ''
        Whether to enable the 1Password SSH identety agent.
      '';
    };

  };

  config.programs = {

    git.extraConfig = lib.mkIf ( cfg.gitSigningKey != "" ) {

      gpg = {
        format = "ssh";
      };

      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };

      commit = {
        gpgsign = true;
      };

      user = {
        signingkey = cfg.gitSigningKey;
      };

    };

    ssh.extraConfig = lib.mkIf ( cfg.sshIdentityAgentHosts != [ ] ) ( lib.foldr (el: acc: el + "\n" + acc) "" ( map ( host: ''
      Host ${host}
        IdentityAgent ~/.1password/agent.sock
    '' ) cfg.sshIdentityAgentHosts ));

  };

}

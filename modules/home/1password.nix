{
  config,
  lib,
  utility,
  pkgs,
  ...
}:
let
  cfg = config.programs._1password;
in
{
  options.programs._1password = with lib; {
    enable = mkEnableOption "1Password configuration";

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
        List of host on which the 1Password SSH agent should act.
      '';
    };

    sshAgentConfig = mkOption {
      type = types.attrs;
      default = null;
      example = {
        ssh-keys = [
          {
            vault = "Private";
            item = "my-key";
          }
        ];
      };
      description = ''
        Config file for the 1Password SSH agent.
        https://developer.1password.com/docs/ssh/agent/config/
      '';
    };

    autostart = {
      enable = mkEnableOption "create 1Password autostart desktop file";

      silent = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Setup desktop file with the `--silent` switch set.
        '';
      };
    };
  };

  config = {
    programs = {
      git.extraConfig = lib.mkIf (cfg.gitSigningKey != "") {
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

      ssh.extraConfig = lib.mkIf (cfg.sshIdentityAgentHosts != [ ]) (
        lib.foldr (el: acc: el + "\n" + acc) "" (
          map (host: ''
            Host ${host}
              IdentityAgent ~/.1password/agent.sock
          '') cfg.sshIdentityAgentHosts
        )
      );
    };

    xdg = {
      configFile."1Password/ssh/agent.toml".text = lib.mkIf (cfg.sshAgentConfig != null) (
        utility.std.serde.toTOML cfg.sshAgentConfig
      );

      autostart = lib.mkIf cfg.autostart.enable {
        enable = lib.mkDefault true;

        entries =
          let
            _1passwordDesktopPath = "${pkgs._1password-gui}/share/applications/1password.desktop";
          in
          if cfg.autostart.silent then
            [
              (pkgs.writeTextFile {
                name = builtins.baseNameOf _1passwordDesktopPath;
                text = lib.strings.replaceString "1password %U" "1password --silent %U" (
                  lib.strings.readFile _1passwordDesktopPath
                );
              })
            ]
          else
            [ _1passwordDesktopPath ];
      };
    };

    wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.autostart.enable [
      ("1password" + (lib.strings.optionalString cfg.autostart.silent " --silent"))
    ];
  };
}

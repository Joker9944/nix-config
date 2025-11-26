{
  config,
  lib,
  utility,
  pkgs,
  ...
}:
let
  cfg = config.programs._1password;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs._1password = with lib; {
    enable = mkEnableOption "1Password configuration";

    gitSigningKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";
      description = ''
        Public key used for git commit signing.
      '';
    };

    blocks = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "*" ];
      description = ''
        List of blocks on which the 1Password SSH agent should act.
      '';
    };

    sshAgentConfig = mkOption {
      inherit (tomlFormat) type;
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
        <https://developer.1password.com/docs/ssh/agent/config/>
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

  config = lib.mkIf cfg.enable {
    programs = {
      git.signing = lib.mkIf (cfg.gitSigningKey != null) {
        format = "ssh";

        key = cfg.gitSigningKey;

        signByDefault = true;

        signer = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };

      ssh.matchBlocks = lib.pipe cfg.blocks [
        (lib.map (name: {
          inherit name;
          value = {
            identityAgent = "~/.1password/agent.sock";
          };
        }))
        lib.listToAttrs
      ];
    };

    xdg = {
      configFile."1Password/ssh/agent.toml".source =
        let
          agentToml = tomlFormat.generate "1password-agent.toml" cfg.sshAgentConfig;
        in
        lib.mkIf (cfg.sshAgentConfig != null) agentToml;

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
  };
}

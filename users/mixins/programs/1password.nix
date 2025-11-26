{
  lib,
  config,
  osConfig,
  custom,
  ...
}:
{
  options.mixins.programs._1password =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "1Password config mixin";

      vault = mkOption {
        type = types.str;
        default = "Private";
      };
    };

  config.programs._1password =
    let
      cfg = config.mixins.programs._1password;
    in
    lib.mkIf cfg.enable {
      enable = true;

      blocks = [ "*" ];

      sshAgentConfig.ssh-keys = [
        {
          inherit (cfg) vault;
          item = "${custom.config.username}@${osConfig.networking.hostName}";
        }
      ];

      autostart.enable = true;
    };
}

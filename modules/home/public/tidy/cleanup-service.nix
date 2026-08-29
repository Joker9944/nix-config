_:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  serviceName = "tidy-cleanup";
  description = "Tidy Cleanup";

  cfg = config.services.tidy.cleanup;

  inherit (import ./timer.nix { inherit lib; }) timerOptions mkTimerUnit;
in
{
  options.services.tidy.cleanup =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "periodic move of stale files into the trash";

      downloads = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to clean up the downloads directory.
          '';
        };

        path = mkOption {
          type = types.str;
          default =
            if config.xdg.userDirs.download != null then
              config.xdg.userDirs.download
            else
              "${config.home.homeDirectory}/Downloads";
          defaultText = literalExpression "config.xdg.userDirs.download";
          description = ''
            Directory to clean up. Set this when the XDG user directories are managed
            outside of home-manager.
          '';
        };

        days = mkOption {
          type = types.ints.positive;
          default = 30;
          example = 90;
          description = ''
            Trash entries whose modification time is older than this many days.
          '';
        };
      };
    }
    // timerOptions;

  config =
    let
      downloadsScript = pkgs.writeShellApplication {
        name = "${serviceName}-downloads";

        runtimeInputs = with pkgs; [
          findutils
          trash-cli
        ];

        text =
          let
            days = toString cfg.downloads.days;
          in
          ''
            dir=${lib.escapeShellArg cfg.downloads.path}
            [ -d "$dir" ] || exit 0
            # Deliberately no -atime: a file manager generating previews reads every entry in the
            # directory, so one browse renews the whole folder. The trash window is the safety net.
            find "$dir" -mindepth 1 -maxdepth 1 -mtime +${days} -exec trash-put -- {} +
          '';
      };

      execStart = lib.optional cfg.downloads.enable (lib.getExe downloadsScript);
    in
    lib.mkIf (cfg.enable && execStart != [ ]) {
      assertions = [
        {
          assertion = !cfg.downloads.enable || cfg.downloads.path != config.home.homeDirectory;
          message = "services.tidy.cleanup.downloads.path must not be the home directory itself.";
        }
      ];

      systemd.user = {
        services.${serviceName} = {
          Unit.Description = description;

          Service = {
            Type = "oneshot";

            ExecStart = execStart;
          };
        };

        timers.${serviceName} = mkTimerUnit { inherit description cfg; };
      };
    };
}

{ libUtil, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  serviceName = "tidy-empty-trash";
  description = "Tidy Empty Trash";

  cfg = config.services.tidy.emptyTrash;

  inherit (import ./timer.nix { inherit lib; }) timerOptions mkTimerUnit;
in
{
  options.services.tidy.emptyTrash =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "periodic purge of the trash";

      days = mkOption {
        type = types.ints.positive;
        default = 30;
        example = 90;
        description = ''
          Purge trash entries deleted more than this many days ago.
        '';
      };

      maxSizeMb = mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
        example = literalExpression "20 * 1024";
        description = ''
          Purge the oldest trash entries until the trash consumes less than this many
          megabytes, regardless of {option}`days`. Null disables the size cap.
        '';
      };
    }
    // timerOptions;

  config = lib.mkIf cfg.enable {
    systemd.user = {
      services.${serviceName} = {
        Unit.Description = description;

        Service = {
          Type = "oneshot";

          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "${serviceName}-start";

              runtimeInputs = with pkgs; [ autotrash ];

              text = libUtil.strings.mkCommand [
                "autotrash"
                "--verbose"
                "--days=${toString cfg.days}"
                (lib.optional (cfg.maxSizeMb != null) "--trash_limit=${toString cfg.maxSizeMb}")
              ];
            }
          );
        };
      };

      timers.${serviceName} = mkTimerUnit { inherit description cfg; };
    };
  };
}

# Timer options and unit shape shared by the tidy services.
# Lifted from https://github.com/NixOS/nixpkgs/blob/1807c2b91223227ad5599d7067a61665c52d1295/nixos/modules/tasks/auto-upgrade.nix
{ lib }:
let
  inherit (lib) mkOption types;
in
{
  timerOptions = {
    dates = mkOption {
      type = types.str;
      default = "daily";
      example = "04:40";
      description = ''
        How often or when the service runs.

        The format is described in
        {manpage}`systemd.time(7)`.
      '';
    };

    randomizedDelaySec = mkOption {
      type = types.str;
      default = "0";
      example = "45min";
      description = ''
        Add a randomized delay before each run.
        The delay will be chosen between zero and this value.
        This value must be a time span in the format specified by
        {manpage}`systemd.time(7)`
      '';
    };

    fixedRandomDelay = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Make the randomized delay consistent between runs.
        This reduces the jitter between runs.
        See {option}`randomizedDelaySec` for configuring the randomized delay.
      '';
    };

    persistent = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Takes a boolean argument. If true, the time when the service
        unit was last triggered is stored on disk. When the timer is
        activated, the service unit is triggered immediately if it
        would have been triggered at least once during the time when
        the timer was inactive. Such triggering is nonetheless
        subject to the delay imposed by RandomizedDelaySec=. This is
        useful to catch up on missed runs of the service when the
        system was powered down.
      '';
    };
  };

  mkTimerUnit =
    { description, cfg }:
    {
      Unit.Description = description;

      Install.WantedBy = [ "timers.target" ];

      Timer = {
        FixedRandomDelay = cfg.fixedRandomDelay;
        OnCalendar = cfg.dates;
        Persistent = cfg.persistent;
        RandomizedDelaySec = cfg.randomizedDelaySec;
      };
    };
}

{
  config,
  lib,
  pkgs,
  utility,
  ...
}:
# Lifted and adapted from https://github.com/NixOS/nixpkgs/blob/1807c2b91223227ad5599d7067a61665c52d1295/nixos/modules/tasks/auto-upgrade.nix
# Remove once issue has been resolved https://github.com/nix-community/home-manager/issues/338
let
  upgradeServiceName = "home-manager-auto-upgrade";

  cfg = config.services.home-manager.autoUpgrade;
in
{
  options.services.home-manager.autoUpgrade =
    let
      inherit (lib) mkOption types;
    in
    {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to periodically upgrade NixOS to the latest
          version. If enabled, a systemd timer will run
          `nixos-rebuild switch --upgrade` once a
          day.
        '';
      };

      flake = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "github:kloenk/nix"; # cSpell:ignore kloenk
        description = ''
          The Flake URI of the NixOS configuration to build.
          Disables the option {option}`system.autoUpgrade.channel`.
        '';
      };

      flags = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "-I"
          "stuff=/home/alice/nixos-stuff"
          "--option"
          "extra-binary-caches"
          "http://my-cache.example.org/"
        ];
        description = ''
          Any additional flags passed to {command}`nixos-rebuild`.

          If you are using flakes and use a local repo you can add
          {command}`[ "--update-input" "nixpkgs" "--commit-lock-file" ]`
          to update nixpkgs.
        '';
      };

      dates = mkOption {
        type = types.str;
        default = "04:40";
        example = "daily";
        description = ''
          How often or when upgrade occurs. For most desktop and server systems
          a sufficient upgrade frequency is once a day.

          The format is described in
          {manpage}`systemd.time(7)`.
        '';
      };

      randomizedDelaySec = mkOption {
        default = "0";
        type = types.str;
        example = "45min";
        description = ''
          Add a randomized delay before each automatic upgrade.
          The delay will be chosen between zero and this value.
          This value must be a time span in the format specified by
          {manpage}`systemd.time(7)`
        '';
      };

      fixedRandomDelay = mkOption {
        default = false;
        type = types.bool;
        example = true;
        description = ''
          Make the randomized delay consistent between runs.
          This reduces the jitter between automatic upgrades.
          See {option}`randomizedDelaySec` for configuring the randomized delay.
        '';
      };

      persistent = mkOption {
        default = true;
        type = types.bool;
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

  # Unload default home-manager auto upgrade service
  disabledModules = [ "services/home-manager-auto-upgrade.nix" ];

  config = lib.mkIf cfg.enable {
    services.home-manager.autoUpgrade.flags = [
      "--refresh"
      "--flake ${cfg.flake}"
    ];

    systemd.user = {
      services.${upgradeServiceName} = {
        Unit = {
          Description = "Home Manager Auto Upgrade";

          Wants = "network-online.target";
          After = "network-online.target";

          X-StopOnRemoval = false;
        };

        Service = {
          Type = "oneshot";

          Environment =
            let
              path =
                with pkgs;
                lib.makeBinPath [
                  home-manager
                  nix
                ];
            in
            "\"PATH=$PATH:${path}\"";

          ExecStart =
            let
              homeManagerCommand = utility.custom.mkCommand [
                "home-manager"
                "switch"
                cfg.flags
              ];
            in
            pkgs.writeShellScript "${upgradeServiceName}-start" ''
              ${homeManagerCommand}
            '';

          X-RestartIfChanged = false;
        };
      };

      timers.${upgradeServiceName} = {
        Unit.Description = "Home Manager Auto Upgrade";

        Install.WantedBy = [ "timers.target" ];

        Timer = {
          FixedRandomDelay = cfg.fixedRandomDelay;
          OnCalendar = cfg.dates;
          Persistent = cfg.persistent;
          RandomizedDelaySec = cfg.randomizedDelaySec;
        };
      };
    };
  };
}

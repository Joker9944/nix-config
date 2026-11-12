{ flake, ... }:
{ lib, pkgs, ... }:
let
  countries = [
    "ch"
    "dk"
    "pt"
  ];

  sets = {
    v4 = "geoblock4";
    v6 = "geoblock6";
  };

  # Headroom over the ~54k v6 prefixes three countries produce.
  maxElem = 131072;

  update = pkgs.writers.writePython3Bin "update-geoblock" {
    doCheck = false;
  } (builtins.readFile ./files/update-geoblock.py);
in
# Rationale: decisions/geoblock-at-the-edge.
{
  networking.firewall = {
    extraPackages = [ pkgs.ipset ];
    extraCommands = flake.lib.network.mkAllowFromSet {
      inherit sets;
      tcp = [ 443 ];
    };
  };

  systemd = {
    services.update-geoblock = {
      description = "Populate the geoblock ipsets from db-ip";
      # The firewall only guarantees the sets exist, possibly empty, so :443 is
      # closed until this has run; being wanted by the firewall repopulates
      # after every firewall start.
      wantedBy = [
        "multi-user.target"
        "firewall.service"
      ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "firewall.service"
      ];

      path = [ pkgs.ipset ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.concatStringsSep " " (
          [
            "${update}/bin/update-geoblock"
            "--v4-set"
            sets.v4
            "--v6-set"
            sets.v6
            "--max-elem"
            (toString maxElem)
          ]
          ++ countries
        );
        StateDirectory = "geoblock";
        # Holds the installed-cache marker, which must outlive each oneshot run
        # but not a reboot.
        RuntimeDirectory = "geoblock";
        RuntimeDirectoryPreserve = true;

        # Exit 1 has nothing to serve and retries; exit 2 serves the cache and
        # waits for the next timer run.
        Restart = "on-failure";
        RestartSec = "30s";
        RestartPreventExitStatus = 2;
      };
    };

    timers.update-geoblock = {
      description = "Daily geoblock prefix refresh";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}

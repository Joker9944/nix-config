{ mkMixinModule, inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  notify = pkgs.writeShellApplication {
    name = "smartd-gotify-notify";
    runtimeInputs = with pkgs; [
      coreutils
      curl
    ];
    runtimeEnv = {
      GOTIFY_URL = "https://gotify.vonarx.online";
      GOTIFY_TOKEN_FILE = config.sops.secrets."smartd/gotify-token".path;
    };
    text = ''
      curl --fail --silent --show-error \
        --header "X-Gotify-Key: $(cat "$GOTIFY_TOKEN_FILE")" \
        --data-urlencode "title=smartd: $SMARTD_FAILTYPE on $SMARTD_DEVICESTRING" \
        --data-urlencode "message=$SMARTD_MESSAGE" \
        --data-urlencode "priority=8" \
        "$GOTIFY_URL/message"
    '';
  };
in
mkMixinModule "smartd" {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."smartd/gotify-token".sopsFile = ./secrets/smartd.yaml;
  };

  # smartd's unit pins its own smartmontools and exports nothing, so smartctl
  # would otherwise be absent for the interactive half of
  # workflows/diagnose-disk-faults.
  environment.systemPackages = [ pkgs.smartmontools ];

  services.smartd = {
    enable = true;

    # Every backend off keeps the module's own notifyOpts empty, so the -M exec
    # below is the only one in the directive. Its mail path is the wrong shape
    # for a push anyway: it pipes a full `smartctl -a` dump into the body.
    notifications.wall.enable = false;

    # defaults.autodetected inherits this, so one assignment covers both an
    # explicit `devices` list (via the generated DEFAULT line, whose directives
    # merge into each device entry) and DEVICESCAN.
    #
    # -o/-S turn on the drive's offline collection and attribute autosave; the
    # schedule is a short test daily at 02:00 and a long one Wednesday 03:00,
    # clear of the monthly scrub. -M exec is only honoured alongside -m, hence
    # the <nomailer> placeholder.
    #
    # -U 199+ is what makes a failing SATA link alertable. `-a` is not "warn on
    # everything": it tracks attribute changes to syslog only, and these drives
    # record interface CRC errors in attribute 199 but not in the Summary SMART
    # error log, so neither -t nor -l error reaches the warning path. Pointing
    # -U at 199 does, and `+` reports increases only, so a drive carrying
    # historical CRC errors from an already-replaced cable is a baseline rather
    # than a permanent alert. It costs the default -U 198: the directive holds
    # one attribute id. Media failure keeps -C 197 and -l selftest.
    defaults.monitored = "-a -o on -S on -U 199+ -s (S/../.././02|L/../../3/03) -m <nomailer> -M exec ${lib.getExe notify}";
  };
}

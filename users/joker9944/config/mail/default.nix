{
  lib,
  pkgs,
  config,
  custom,
  ...
}:
{
  imports = [ ./aerc-defaults.nix ];

  config =
    let
      bin = {
        cat = lib.getExe' pkgs.coreutils "cat";
        mbsync = lib.getExe config.programs.mbsync.package;
      };
    in
    lib.pipe ./accounts.nix [
      (accountsPath: import accountsPath custom)
      lib.attrsToList
      (lib.map (
        entry:
        let
          id = entry.name;
          inherit (entry.value) name;
          account = lib.removeAttrs entry.value [ "name" ];

          mkPasswordCommand =
            lib.pipe
              ''
                ${bin.cat} "${config.sops.secrets."accounts/email/${id}".path}"
              ''
              [
                (pkgs.writeShellScript "${name}")
                toString
              ];

          mkNotifyCommand =
            let
              notifyScript = pkgs.writeShellApplication {
                name = "mbsync-notify";

                text = lib.readFile ./files/mbsync-notify.sh;

                runtimeInputs = with pkgs; [
                  coreutils
                  findutils
                  gnused
                  gawk
                  procmail
                  libnotify
                ];

                # Options are set in the script itself
                bashOptions = [ ];

                runtimeEnv = {
                  MAILDIR = config.accounts.email.maildirBasePath;
                  MAIL_NOTIFY_ICON =
                    let
                      inherit (config.gtk) iconTheme;
                    in
                    "${iconTheme.package}/share/icons/${iconTheme.name}/scalable/apps/email.svg";
                };
              };

              hookScript = pkgs.writeShellApplication {
                name = "on-new-mail";

                text = ''
                  CHANNEL=$1
                  MAILBOX=$2

                  mbsync "$CHANNEL:$MAILBOX"
                  mbsync-notify "$CHANNEL" "$MAILBOX"
                '';

                runtimeInputs = [
                  config.programs.mbsync.package
                  notifyScript
                ];
              };
            in
            "${lib.getExe hookScript} ${name} %s";
        in
        {
          accounts.email.accounts.${name} = lib.recursiveUpdate account {
            passwordCommand = mkPasswordCommand;

            imapnotify = {
              enable = true;

              onNotify = mkNotifyCommand;
            };

            aerc = {
              enable = true;

              extraAccounts.check-mail-cmd = "${bin.mbsync} ${name}";
            };

            mbsync = {
              enable = true;

              create = "both";
              expunge = "both";
            };
          };

          systemd.user.services."imapnotify-${name}".Unit.After = "sops-nix.service";
          sops.secrets."accounts/email/${id}" = { };
        }
      ))
      (lib.foldl (acc: cfg: lib.recursiveUpdate acc cfg) { })
      (lib.recursiveUpdate {
        accounts.email.maildirBasePath = ".mail";

        programs = {
          aerc = {
            enable = true;

            extraConfig.general.unsafe-accounts-conf = lib.mkForce true;
          };

          mbsync.enable = true;
        };

        services = {
          imapnotify.enable = true;

          dunst.settings.mbsync = {
            appname = "mbsync";
            word_wrap = false;
            ellipsize = "end";
          };
        };
      })
    ];
}

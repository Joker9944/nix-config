{
  lib,
  pkgs,
  config,
  utility,
  ...
}:
let
  bin = {
    cat = "${pkgs.coreutils}/bin/cat";
    notify-send = "${pkgs.libnotify}/bin/notify-send";
  };

  mkPasswordCommand =
    id:
    toString (
      pkgs.writeShellScript id ''
        ${bin.cat} "${config.sops.secretHome}/accounts/email/${id}"
      ''
    );

  mkNotifyCommand =
    name:
    "${bin.notify-send} --app-name imapnotify --urgency normal --category mail \"New mail arrived: ${name} %s\"";

  accounts = import ./accounts.nix utility;

  addressConfigs = lib.map (
    entry:
    let
      id = entry.name;
      account = entry.value;
    in
    {
      accounts.email.accounts.${account.name} = {
        inherit (account)
          primary
          address
          realName
          userName
          imap
          smtp
          ;

        passwordCommand = mkPasswordCommand id;

        imapnotify = {
          inherit (account) boxes;
          enable = true;

          onNotify = mkNotifyCommand account.address;
        };
      };

      systemd.user.services."imapnotify-${account.name}".Unit.After = "sops-nix.service";
      sops.secrets."accounts/email/${id}" = { };
    }
  ) (lib.attrsToList accounts);
in
(lib.foldl (acc: cfg: lib.recursiveUpdate acc cfg) { } addressConfigs)
// {
  services.imapnotify = {
    enable = true;
  };
}

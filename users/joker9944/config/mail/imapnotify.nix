{
  lib,
  pkgs,
  config,
  custom,
  ...
}:
let
  bin = {
    cat = lib.getExe' pkgs.coreutils "cat";
    notify-send = lib.getExe pkgs.libnotify;
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

  accounts = import ./accounts.nix custom;

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
  home.packages = [ pkgs.libnotify ];

  services.imapnotify = {
    enable = true;
  };
}

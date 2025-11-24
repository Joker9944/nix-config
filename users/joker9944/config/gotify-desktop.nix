{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  hostname = osConfig.networking.hostName;
in
{
  services.gotify-desktop = {
    enable = true;
    url = "wss://gotify.vonarx.online";
    token.command =
      let
        bin.cat = lib.getExe' pkgs.coreutils "cat";
      in
      "${bin.cat} ${config.sops.secrets."accounts/gotify/${hostname}".path}";
  };

  sops.secrets."accounts/gotify/${hostname}" = { };
}

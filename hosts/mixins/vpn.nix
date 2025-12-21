{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.mixins.services.vpn =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "VPN configs";
    };

  config.networking.networkmanager =
    let
      cfg = config.mixins.services.vpn;

      ch = {
        id = "CH";
        peerPublicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
      };
    in
    lib.mkIf cfg.enable {
      dispatcherScripts = [
        {
          source = pkgs.writeShellScript "ssid-whitelist.sh" ''
            INTERFACE="$1"
            EVENT="$2"

            # TODO
            # check if interface is network
            # check if connection id is in whitelist
            # if not up vpn
            # ?
            # profit
          '';
          type = "pre-up";
        }
      ];

      ensureProfiles = {
        profiles.ch = {
          connection = {
            inherit (ch) id;
            interface-name = ch.id;
            type = "wireguard";
            autoconnect = false;
          };

          wireguard = {
            mtu = 1320;
            private-key-flags = 1; # agent-owned
          };

          "wireguard-peer.${ch.peerPublicKey}" = {
            endpoint = "ch3.vpn.airdns.org:1637"; # cSpell:ignore airdns
            preshared-key-flags = 1; # agent-owned
            persistent-keepalive = 15;
            allowed-ips = "0.0.0.0/0;::/0;";
          };

          ipv4 = {
            #address1 = "10.128.0.0/10";
            dns = "10.128.0.1;";
            dns-search = "~;";
            method = "manual";
          };

          ipv6 = {
            addr-gen-mode = "default";
            #address1 = "fd7d:76ee:e68f:a993::/64";
            dns = "fd7d:76ee:e68f:a993::1;";
            dns-search = "~;";
            method = "manual";
          };
        };

        secrets.entries = [
          {
            matchId = "CH";
            matchType = "wireguard";
            matchSetting = "wireguard";
            key = "private-key";
            file = config.sops.secrets."vpn/ch/private-key".path;
          }
          {
            matchId = "CH";
            matchType = "wireguard";
            matchSetting = "wireguard";
            key = "peers.${ch.peerPublicKey}.preshared-key";
            file = config.sops.secrets."vpn/ch/preshared-key".path;
          }
        ];
      };
    };
}

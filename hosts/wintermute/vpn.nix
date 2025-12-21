{
  networking.networkmanager = {
    custom.vpn.enable = true;

    ensureProfiles.profiles.ch = {
      ipv4.address1 = "10.152.197.2/32";
      ipv6.address1 = "fd7d:76ee:e68f:a993:97e2:b422:e115:cc5d/128";
    };
  };

  sops.secrets = {
    "vpn/ch/private-key" = {
      sopsFile = ./secrets/vpn.yaml;
    };

    "vpn/ch/preshared-key" = {
      sopsFile = ./secrets/vpn.yaml;
    };
  };
}

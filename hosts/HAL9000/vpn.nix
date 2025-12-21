{
  networking.networkmanager = {
    #  custom.vpn.enable = true;

    ensureProfiles.profiles.ch = {
      ipv4.address1 = "10.161.158.27/32";
      ipv6.address1 = "fd7d:76ee:e68f:a993:3676:3ca7:14ca:4d40/128";
    };
  };

  mixins.services.vpn.enable = true;

  sops.secrets = {
    "vpn/ch/private-key" = {
      sopsFile = ./secrets/vpn.yaml;
      owner = "root";
      group = "networkmanager";
      mode = "0440";
    };

    "vpn/ch/preshared-key" = {
      sopsFile = ./secrets/vpn.yaml;
      owner = "root";
      group = "networkmanager";
      mode = "0440";
    };
  };
}

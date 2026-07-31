{ mkMixinModule, inputs, ... }:
{
  config,
  lib,
  ...
}:
mkMixinModule "k3s" {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config = {
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      defaultSopsFile = ../../../../secrets/k3s.yaml;
      secrets."k3s/token" = { };
    };

    services.k3s = {
      enable = true;
      role = lib.mkDefault "server";
      tokenFile = config.sops.secrets."k3s/token".path;
      disable = [
        "traefik"
        "servicelb"
        "local-storage"
      ];
    };

    # Longhorn node prerequisites
    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
    };

    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
        2379
        2380
      ];
      allowedUDPPorts = [ 8472 ];
      trustedInterfaces = [
        "cni0"
        "flannel.1"
      ];
    };
  };
}

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
      secrets."k3s/token".sopsFile = ./secrets/k3s.yaml;
    };

    services.k3s = {
      enable = true;
      role = lib.mkDefault "server";
      tokenFile = config.sops.secrets."k3s/token".path;
      # `k3s agent` does not define --disable; passing it there is fatal.
      disable = lib.optionals (config.services.k3s.role == "server") [
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

    # Puts nfs-utils in system.fsPackages, which is where kubelet finds
    # mount.nfs. Without it a node silently cannot mount Longhorn RWX volumes
    # or any pod-level NFS share.
    boot.supportedFilesystems.nfs = true;

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

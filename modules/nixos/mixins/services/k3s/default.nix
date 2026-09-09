{ mkMixinModule, inputs, ... }:
{
  config,
  lib,
  pkgs,
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
      # kube-proxy defaults its metrics to 127.0.0.1:10249, unreachable by a
      # scraper on another node. Ungated: kube-proxy runs on every node and k3s
      # tags --kube-proxy-arg (agent/flags), so servers accept it too.
      extraFlags = [ "--kube-proxy-arg=metrics-bind-address=0.0.0.0" ];
    };

    # k3s LookPaths $PATH for nvidia-container-runtime[.cdi] and writes the
    # matching containerd runtime handlers into its generated config. The
    # toolkit installs those binaries on no path of its own, so without this
    # the handlers never appear and runtimeClassName resolves to nothing.
    systemd.services.k3s.path = lib.optional config.hardware.nvidia-container-toolkit.enable pkgs.nvidia-container-toolkit.tools;

    # Longhorn node prerequisites
    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
    };

    # Puts nfs-utils in system.fsPackages, which is where kubelet finds
    # mount.nfs. Without it a node silently cannot mount Longhorn RWX volumes
    # or any pod-level NFS share.
    boot.supportedFilesystems.nfs = true;

    # HACK
    # longhorn-manager probes the host with `nsenter <host ns> <tool>`, which
    # keeps the *container's* PATH. None of the FHS directories in that PATH
    # exist here, so the tools are unreachable however they are installed.
    # /usr/bin is the one NixOS already populates (env), so the links go there.
    # https://github.com/longhorn/longhorn/issues/2166
    systemd.tmpfiles.rules =
      map (name: "L+ /usr/bin/${name} - - - - /run/current-system/sw/bin/${name}")
        [
          "iscsiadm"
          "mount"
          "umount"
          "mount.nfs"
          "mount.nfs4"
        ];

    networking.firewall = {
      allowedTCPPorts = [
        6443 # kube-apiserver
        10250 # kubelet API
        2379 # etcd client
        2380 # etcd peer
        # Metrics. Both bind the host netns rather than a pod IP, so a scrape
        # from the node Prometheus happens to run on is the only one arriving
        # over a trusted interface; the other three cross the LAN.
        9100 # node-exporter
        10249 # kube-proxy
      ];
      allowedUDPPorts = [ 8472 ]; # flannel VXLAN
      trustedInterfaces = [
        "cni0" # pod veth bridge
        "flannel.1" # VXLAN overlay
      ];
    };
  };
}

{
  mkMixinModule,
  flake,
  inputs,
  ...
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  isNvidiaGpu = config.hardware.nvidia-container-toolkit.enable;
  isNfs = config.services.nfs.server.enable;

  isServer = config.services.k3s.role == "server";

  nodes = flake.lib.network.nyxNodes;
  nodeAddresses = lib.attrValues nodes;
  hostName = config.networking.hostName;
  nodeAddress =
    lib.throwIf (!lib.hasAttr hostName nodes)
      "k3s mixin: ${hostName} has no entry in lib/network/nyxNodes.nix; every node must be listed there"
      nodes.${hostName};

  # Pods reach a node through its LAN address, not the overlay, so the scrape
  # arrives on an interface outside trustedInterfaces. Flannel's ipMasq SNATs it
  # to the sending node's address, so the node list already covers it; the pod
  # CIDR is redundant insurance against that behaviour changing, which would
  # break scraping on every node at once.
  podCidr = "10.42.0.0/16";
  tailnet = "100.64.0.0/10";

  wg = flake.lib.network.wgEdge;
  wgSpoke =
    lib.throwIf (!lib.hasAttr hostName wg.spokes)
      "k3s mixin: ${hostName} is a server but has no entry in lib/network/wgEdge.nix; the ingress tunnel needs a transit address and public key per server"
      wg.spokes.${hostName};
in
mkMixinModule "k3s" {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config = {
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets = {
        "k3s/token".sopsFile = ./secrets/k3s.yaml;
      }
      // lib.optionalAttrs isServer {
        "wireguard/${hostName}/private-key".sopsFile = ./secrets/wireguard.yaml;
      };
    };

    services.k3s = {
      enable = true;
      role = lib.mkDefault "server";
      tokenFile = config.sops.secrets."k3s/token".path;
      # `k3s agent` does not define --disable; passing it there is fatal.
      disable = lib.optionals isServer [
        "traefik"
        "servicelb"
        "local-storage"
      ];
      # kube-proxy defaults its metrics to 127.0.0.1:10249, unreachable by a
      # scraper on another node. The node address rather than 0.0.0.0 keeps it
      # off tailscale0 and every other interface. Ungated: kube-proxy runs on
      # every node and k3s tags --kube-proxy-arg (agent/flags), so servers
      # accept it too.
      extraFlags = [ "--kube-proxy-arg=metrics-bind-address=${nodeAddress}" ];

      nodeLabel =
        (lib.optional isNvidiaGpu "nvidia.com/gpu.present=true")
        ++ (lib.optional isNfs "vonarx.online/nfs-host=true");
    };

    # Spoke of the public ingress tunnel. wopr holds the only public address, so
    # it listens and each server dials out; the keepalive is what holds the
    # conntrack entry on the CGNAT'd uplink open so the hub can reach back in.
    # Server-only and uniform, hence here rather than in three identical host
    # files — mother is an agent and runs no Traefik pod.
    networking.wireguard.interfaces = lib.optionalAttrs isServer {
      wg0 = {
        ips = [ "${wgSpoke.address}/32" ];
        privateKeyFile = config.sops.secrets."wireguard/${hostName}/private-key".path;
        peers = [
          {
            inherit (wg.hub) publicKey;
            endpoint = "${wg.endpoint.address}:${toString wg.endpoint.port}";
            allowedIPs = [ "${wg.hub.address}/32" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };

    systemd = {
      # The generated unit sets only Name and address, and a wireguard link that
      # never reaches routable would hang systemd-networkd-wait-online for its
      # full timeout.
      network.networks = lib.optionalAttrs isServer {
        "40-wg0".linkConfig.RequiredForOnline = "no";
      };

      # k3s LookPaths $PATH for nvidia-container-runtime[.cdi] and writes the
      # matching containerd runtime handlers into its generated config. The
      # toolkit installs those binaries on no path of its own, so without this
      # the handlers never appear and runtimeClassName resolves to nothing.
      services.k3s.path = lib.optional isNvidiaGpu pkgs.nvidia-container-toolkit.tools;
    };

    # Longhorn node prerequisites
    # Longhorn's node check reports dm_crypt missing even where no encrypted
    # volume exists, and nothing on these nodes autoloads it.
    boot.kernelModules = [ "dm_crypt" ];

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
          "fstrim"
        ];

    networking.firewall = {
      trustedInterfaces = [
        "cni0" # pod veth bridge
        "flannel.1" # VXLAN overlay
      ];

      # Nothing here goes in allowedTCPPorts: that opens a port to every source
      # on every interface, and all of these have a known set of peers.
      extraCommands = lib.concatStringsSep "\n" (
        [
          (flake.lib.network.mkAllowFrom {
            sources = nodeAddresses;
            tcp = [ 7946 ]; # metallb peering
            udp = [
              8472 # flannel VXLAN
              7946 # metallb gossip
            ];
          })
          (flake.lib.network.mkAllowFrom {
            sources = nodeAddresses ++ [ podCidr ];
            tcp = [
              10250 # kubelet API
              9100 # node-exporter
              10249 # kube-proxy
            ];
          })
        ]
        # kube-apiserver and the embedded etcd only run on servers, so an agent
        # opens neither. The CGNAT range is belt-and-braces, not what admits
        # kubectl today: tailscaled installs its own ts-input ACCEPT at the head
        # of INPUT, so nothing arriving on tailscale0 ever reaches nixos-fw.
        ++ lib.optionals isServer [
          (flake.lib.network.mkAllowFrom {
            sources = nodeAddresses ++ [ tailnet ];
            tcp = [ 6443 ]; # kube-apiserver
          })
          (flake.lib.network.mkAllowFrom {
            sources = nodeAddresses;
            tcp = [
              2379 # etcd client
              2380 # etcd peer
            ];
          })
          # wg0 is deliberately not a trusted interface, so the edge's whole
          # reach across the tunnel is this one port.
          (flake.lib.network.mkAllowFrom {
            sources = [ wg.hub.address ];
            tcp = [ wg.nodePort ]; # traefik websecure-proxied
          })
        ]
      );
    };
  };
}

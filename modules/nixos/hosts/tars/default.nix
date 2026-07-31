{ flake, ... }@args:
let
  # kube-vip control-plane VIP, ARP mode. Reclaims the Talos L2 VIP so the k3s
  # registration endpoint (serverAddr on case/kipp/mother) stays 192.168.0.20:6443.
  # TODO before deploy: pin the kube-vip version and set vip_interface to the
  # NUC's wired interface name (see hardware-configuration.nix / `ip link`).
  vip = "192.168.0.20";
  kubeVipImage = "ghcr.io/kube-vip/kube-vip:v0.8.9";
  vipInterface = "eth0";
in
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;
    inherit args;
  }
  {
    networking.hostName = "tars";

    systemd.network.networks."10-lan" = {
      matchConfig.Name = "en*";
      address = [ "192.168.0.21/23" ];
      routes = [ { Gateway = "192.168.1.1"; } ];
      dns = [ "192.168.1.1" ];
      linkConfig.RequiredForOnline = "routable";
    };

    services.k3s = {
      clusterInit = true;
      nodeLabel = [
        # TODO port the vonarx.online/* labels from the Talos node config.
        "vonarx.online/role=control-plane"
      ];
      manifests.kube-vip.content = [
        {
          apiVersion = "v1";
          kind = "ServiceAccount";
          metadata = {
            name = "kube-vip";
            namespace = "kube-system";
          };
        }
        {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRole";
          metadata = {
            name = "system:kube-vip-role";
            annotations."rbac.authorization.kubernetes.io/autoupdate" = "true";
          };
          rules = [
            {
              apiGroups = [ "" ];
              resources = [
                "services"
                "services/status"
                "nodes"
                "endpoints"
              ];
              verbs = [
                "list"
                "get"
                "watch"
                "update"
              ];
            }
            {
              apiGroups = [ "coordination.k8s.io" ];
              resources = [ "leases" ];
              verbs = [
                "list"
                "get"
                "watch"
                "update"
                "create"
              ];
            }
          ];
        }
        {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRoleBinding";
          metadata.name = "system:kube-vip-binding";
          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            name = "system:kube-vip-role";
          };
          subjects = [
            {
              kind = "ServiceAccount";
              name = "kube-vip";
              namespace = "kube-system";
            }
          ];
        }
        {
          apiVersion = "apps/v1";
          kind = "DaemonSet";
          metadata = {
            name = "kube-vip-ds";
            namespace = "kube-system";
            labels."app.kubernetes.io/name" = "kube-vip-ds";
          };
          spec = {
            selector.matchLabels."app.kubernetes.io/name" = "kube-vip-ds";
            template = {
              metadata.labels."app.kubernetes.io/name" = "kube-vip-ds";
              spec = {
                affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms = [
                  {
                    matchExpressions = [
                      {
                        key = "node-role.kubernetes.io/control-plane";
                        operator = "Exists";
                      }
                    ];
                  }
                ];
                containers = [
                  {
                    name = "kube-vip";
                    image = kubeVipImage;
                    imagePullPolicy = "IfNotPresent";
                    args = [ "manager" ];
                    env = [
                      {
                        name = "vip_arp";
                        value = "true";
                      }
                      {
                        name = "port";
                        value = "6443";
                      }
                      {
                        name = "vip_interface";
                        value = vipInterface;
                      }
                      {
                        name = "vip_cidr";
                        value = "32";
                      }
                      {
                        name = "cp_enable";
                        value = "true";
                      }
                      {
                        name = "cp_namespace";
                        value = "kube-system";
                      }
                      {
                        name = "svc_enable";
                        value = "false";
                      }
                      {
                        name = "vip_leaderelection";
                        value = "true";
                      }
                      {
                        name = "address";
                        value = vip;
                      }
                    ];
                    securityContext.capabilities.add = [
                      "NET_ADMIN"
                      "NET_RAW"
                    ];
                  }
                ];
                hostNetwork = true;
                serviceAccountName = "kube-vip";
                tolerations = [
                  {
                    effect = "NoSchedule";
                    operator = "Exists";
                  }
                  {
                    effect = "NoExecute";
                    operator = "Exists";
                  }
                ];
              };
            };
          };
        }
      ];
    };

    # This value determines the NixOS release from which the default settings for
    # stateful data were taken. Leave at the release of the first install.
    system.stateVersion = "26.05";
  }

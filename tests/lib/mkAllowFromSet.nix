{ flakeLib, ... }:
let
  inherit (flakeLib.network) mkAllowFromSet;

  sets = {
    v4 = "geoblock4";
    v6 = "geoblock6";
  };

  create =
    suffix: family:
    "ipset list -n geoblock${suffix} >/dev/null 2>&1 || ipset create geoblock${suffix} hash:net family ${family}";

  rule =
    command: suffix: proto: ports:
    "${command} -w -A nixos-fw -m set --match-set geoblock${suffix} src -p ${proto} -m multiport --dports ${ports} -j nixos-fw-accept";
in
{
  testBothFamiliesCreatedAndMatched = {
    expr = mkAllowFromSet {
      inherit sets;
      tcp = [ 443 ];
    };
    expected = builtins.concatStringsSep "\n" [
      (create "4" "inet")
      (create "6" "inet6")
      (rule "iptables" "4" "tcp" "443")
      (rule "ip6tables" "6" "tcp" "443")
    ];
  };

  testOneRulePerProtocolAndFamily = {
    expr = mkAllowFromSet {
      inherit sets;
      tcp = [
        443
        8443
      ];
      udp = [ 443 ];
    };
    expected = builtins.concatStringsSep "\n" [
      (create "4" "inet")
      (create "6" "inet6")
      (rule "iptables" "4" "tcp" "443,8443")
      (rule "ip6tables" "6" "tcp" "443,8443")
      (rule "iptables" "4" "udp" "443")
      (rule "ip6tables" "6" "udp" "443")
    ];
  };

  testNoPortsThrows = {
    expr =
      (builtins.tryEval (mkAllowFromSet {
        inherit sets;
      })).success;
    expected = false;
  };

  testSetMultiportLimitThrows = {
    expr =
      (builtins.tryEval (mkAllowFromSet {
        inherit sets;
        tcp = builtins.genList (i: 1000 + i) 16;
      })).success;
    expected = false;
  };
}

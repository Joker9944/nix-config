{ flakeLib, ... }:
let
  inherit (flakeLib.network) mkAllowFrom;

  rule =
    source: proto: ports:
    "iptables -w -A nixos-fw -s ${source} -p ${proto} -m multiport --dports ${ports} -j nixos-fw-accept";
in
{
  testOneRulePerSourceAndProtocol = {
    expr = mkAllowFrom {
      sources = [
        "192.168.0.21"
        "10.42.0.0/16"
      ];
      tcp = [
        9100
        10249
      ];
      udp = [ 8472 ];
    };
    expected = builtins.concatStringsSep "\n" [
      (rule "192.168.0.21" "tcp" "9100,10249")
      (rule "10.42.0.0/16" "tcp" "9100,10249")
      (rule "192.168.0.21" "udp" "8472")
      (rule "10.42.0.0/16" "udp" "8472")
    ];
  };

  testOmittedProtocolEmitsNothing = {
    expr = mkAllowFrom {
      sources = [ "192.168.0.21" ];
      tcp = [ 2049 ];
    };
    expected = rule "192.168.0.21" "tcp" "2049";
  };

  testEmptySourcesThrows = {
    expr =
      (builtins.tryEval (mkAllowFrom {
        sources = [ ];
        tcp = [ 2049 ];
      })).success;
    expected = false;
  };

  testMultiportLimitThrows = {
    expr =
      (builtins.tryEval (mkAllowFrom {
        sources = [ "192.168.0.21" ];
        tcp = builtins.genList (i: 1000 + i) 16;
      })).success;
    expected = false;
  };
}

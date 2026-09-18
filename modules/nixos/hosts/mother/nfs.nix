{ flake, ... }:
{ lib, ... }:
let
  nodeAddresses = lib.attrValues flake.lib.network.nyxNodes;
in
{
  # The cluster is the only client. The firewall rule and the export ACL are
  # built from the same list, so neither can drift from the other. NFSv4 only:
  # rpcbind's 111 stays closed, so clients must not fall back to v3.
  networking.firewall.extraCommands = flake.lib.network.mkAllowFrom {
    sources = nodeAddresses;
    tcp = [ 2049 ];
  };

  # The path is the pool default: no dataset sets a local mountpoint, so an
  # import without an altroot mounts at /chronos/* (TrueNAS used altroot=/mnt).
  services.nfs.server.exports = ''
    /chronos/media-data  ${
      lib.concatMapStringsSep " " (address: "${address}(sec=sys,rw,no_subtree_check)") nodeAddresses
    }
  '';
}

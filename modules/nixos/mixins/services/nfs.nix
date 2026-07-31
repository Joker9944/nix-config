{ mkMixinModule, ... }:
mkMixinModule "nfs" {
  services.nfs.server.enable = true;

  # NFSv4 only needs 2049; exports themselves are a host delta.
  networking.firewall.allowedTCPPorts = [ 2049 ];
}

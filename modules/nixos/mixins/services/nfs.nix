{ mkMixinModule, ... }:
mkMixinModule "nfs" {
  services.nfs.server.enable = true;

  # No firewall rule here. NFSv4 needs only 2049, but who may reach it is the
  # same decision as who appears in the export ACL, and exports are a host delta.
}

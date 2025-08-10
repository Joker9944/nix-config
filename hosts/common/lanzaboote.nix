{
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.sbctl];

  # TODO lanzaboote seems jank, migrate to Limine once stable.
  # https://wiki.nixos.org/wiki/Limine
  boot.lanzaboote = {
    pkiBundle = "/var/lib/sbctl";
    #configurationLimit = 10;
  };
}

{ flake, ... }:
{
  imports = [ flake.nixosModules.profiles-base ];

  custom.themes.orchidlift-lume.enable = true;

  mixins = {
    boot.loader.limine.enable = true;

    fonts.enable = true;

    networking.networkmanager.enable = true;

    programs = {
      _1password.enable = true;
      gnupg.enable = true;
      home-manager.enable = true;
    };

    services = {
      pipewire.enable = true;
      printing.enable = true;
    };
  };

  programs.localsend.enable = true;

  nix.settings = {
    substituters = [ "https://nix-cache.stoat-herring.ts.net" ];
    trusted-public-keys = [
      "nix-cache.stoat-herring.ts.net-1:Q8Axjlr/ajRNF9b7QXlHfD6OUC03hzMgiE5DJEiXUwg=" # cSpell:disable-line
    ];
    # Off the tailnet the cache is unreachable; fail over to building fast.
    connect-timeout = 5;
  };

  console.useXkbConfig = true;
}

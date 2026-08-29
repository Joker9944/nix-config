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

  console.useXkbConfig = true;
}

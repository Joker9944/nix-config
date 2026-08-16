{
  imports = [ ./base.nix ];

  mixins = {
    boot.loader.limine.enable = true;

    fonts.enable = true;

    networking.networkmanager.enable = true;

    theme.orchidlift-lume.enable = true;

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

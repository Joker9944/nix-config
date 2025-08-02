{
  pkgs,
  pkgs-unstable,
  osConfig,
  ...
}: {
  xdg.autostart.entries = ["${osConfig.programs.steam.package}/share/applications/steam.desktop"];

  home.packages = with pkgs; [
    prismlauncher
  ];

  programs = {
    btop.package = pkgs.btop-cuda;

    _1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";

    lutris = {
      enable = true;
      extraPackages = with pkgs; [mangohud winetricks gamemode umu-launcher];
      protonPackages = [pkgs-unstable.proton-ge-bin];
      steamPackage = osConfig.programs.steam.package;
    };
  };

  gnome-settings.peripherals.touchpad.enable = false;
}

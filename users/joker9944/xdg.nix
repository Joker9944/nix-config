{ pkgs, ...}:

{
  imports = [ "github:Zocker1999NET/home-manager-xdg-autostart" ];

  xgd.autoStart.packages = with pkgs; [
    steam
    telegram-desktop
  ];
}

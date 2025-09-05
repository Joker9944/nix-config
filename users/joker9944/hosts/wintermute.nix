{ custom, ... }: {
  programs._1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcft6944G+ygfWr5wT50TJUQ5f0dAKAr6H4QKSEAsUV";

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1, 3840x2160@60.00Hz, 0x0, 2"
    ];
  };

  services.hyprpaper.settings = let
    wallpaper = "${
      custom.assets.images.backgrounds.totoro-minimalist.${custom.config.resolution}
    }/share/backgrounds/totoro-minimalist.${custom.config.resolution}.png";
  in {
      preload = [ wallpaper ];

      wallpaper = [ ", ${wallpaper}" ];
  };
}

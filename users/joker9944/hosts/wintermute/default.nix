{
  programs._1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcft6944G+ygfWr5wT50TJUQ5f0dAKAr6H4QKSEAsUV";

  mixins.desktopEnvironment.hyprland = {
    system.environment = {
      GDK_SCALE = 2;
    };

    waybar = {
      battery = true;
      stylus = true;
    };
  };

  programs.yas.config.battery = true;

  mixins.services.wayvnc.enable = true;
}

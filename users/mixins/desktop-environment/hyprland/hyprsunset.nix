{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  config.services.hyprsunset = {
    enable = true;
    package = pkgs-hyprland.hyprsunset;

    settings = {
      profile = [
        {
          time = "07:30";
          identity = true;
        }
        {
          time = "21:00";
          temperature = 5000;
          gamma = 0.8;
        }
      ];
    };
  };
}

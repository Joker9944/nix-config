{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  disabledModules = [ "services/hyprsunset.nix" ];
  imports =
    let
      repo = pkgs-hyprland.fetchFromGitHub {
        owner = "nix-community";
        repo = "home-manager";
        rev = "2f588d275ebd8243be6c29e7bf3ec7409baa0aa7";
        sha256 = "sha256-OjnjoalP00CyV34zg6T+Un2QoYiHCdRvMbqrweopyyY=";
      };
    in
    [ "${repo}/modules/services/hyprsunset.nix" ];

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

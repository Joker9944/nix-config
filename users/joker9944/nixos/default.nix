{
  inputs,
  lib,
  config,
  custom,
  ...
}:
let
  username = "joker9944";
in
{
  users = {
    users.${username} = {
      uid = 1000;
      isNormalUser = true;
      group = username;
      createHome = true;
      home = "/home/${username}";
      homeMode = "750";
      description = "Felix von Arx";
      extraGroups = [
        "wheel"
        "keys"
      ]
      ++ lib.optional config.mixins.networking.networkmanager.enable "networkmanager"
      ++ lib.optional config.mixins.virtualisation.docker.enable "docker"
      ++ lib.optional config.mixins.programs.steam.enable "gamemode";

      openssh.authorizedKeys.keys =
        (lib.optional (
          config.networking.hostName != "wintermute"
        ) "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcft6944G+ygfWr5wT50TJUQ5f0dAKAr6H4QKSEAsUV joker9944")
        ++ (lib.optional (
          config.networking.hostName != "HAL9000"
        ) "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg joker9944");
    };

    groups.${username} = {
      gid = 1000;
      members = [ username ];
    };
  };

  # These serve the home-manager side, which reuses the system nixpkgs config and only exists on
  # graphical hosts, so both are gated on it — a server has no home-manager and needs neither.
  custom.nixpkgsCompat.allowUnfreePackages = lib.mkIf config.mixins.programs.home-manager.enable [
    "spotify"
    "idea"
    "pycharm"
    "webstorm"
    "lens-desktop"
    "vscode-extension-ms-vscode-remote-remote-containers"
    "teamspeak3"
    "zoom"
    "goland"
    "claude-code"
    "code"
    "vscode"
  ];

  nixpkgs.overlays = lib.mkIf config.mixins.programs.home-manager.enable [
    inputs.audiomenu.overlays.default
  ];

  # WORKAROUND Setting the profile avatar from home manager using the AccountsService is not documented so this has to suffice
  systemd.tmpfiles.rules = lib.mkIf config.mixins.desktopEnvironment.gnome.enable [
    "f+ /var/lib/AccountsService/users/${username}  0600 root root - [User]\\nSession=\\nIcon=/var/lib/AccountsService/icons/${username}\\nSystemAccount=false\\n"
    "L+ /var/lib/AccountsService/icons/${username}  - - - - ${custom.assets.the-seer}"
  ];
}

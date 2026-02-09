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
        "networkmanager"
        "wheel"
        "keys"
        "docker"
        "gamemode"
      ];

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

  # Since NixOS system config is reused unfree packages have to be configured here, not optimal but an exactable trade off
  custom.nixpkgsCompat.allowUnfreePackages = [
    "spotify"
    "idea"
    "pycharm"
    "webstorm"
    "lens-desktop"
    "vscode-extension-ms-vscode-remote-remote-containers"
    "teamspeak3"
    "zoom"
    "goland"
  ];

  nixpkgs.overlays = [ inputs.audiomenu.overlays.default ];

  # WORKAROUND Setting the profile avatar from home manager using the AccountsService is not documented so this has to suffice
  systemd.tmpfiles.rules = lib.mkIf config.mixins.desktopEnvironment.gnome.enable [
    "f+ /var/lib/AccountsService/users/${username}  0600 root root - [User]\\nSession=\\nIcon=/var/lib/AccountsService/icons/${username}\\nSystemAccount=false\\n"
    "L+ /var/lib/AccountsService/icons/${username}  - - - - ${custom.assets.the-seer}/share/profile/the-seer.jpg"
  ];
}

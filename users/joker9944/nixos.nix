{
  lib,
  config,
  custom,
  ...
}: let
  username = "joker9944";
in {
  users = {
    users.${username} = {
      uid = 1000;
      isNormalUser = true;
      group = username;
      createHome = true;
      home = "/home/${username}";
      homeMode = "750";
      description = "Felix von Arx";
      extraGroups = ["networkmanager" "wheel" "keys" "docker"];
    };

    groups.${username} = {
      gid = 1000;
      members = [username];
    };
  };

  # WORKAROUND Setting the profile avatar from userspace using the AccountsService is not documented so this has to suffice
  systemd.tmpfiles.rules = lib.mkIf config.desktopEnvironment.gnome.enable [
    "f+ /var/lib/AccountsService/users/${username}  0600 root root - [User]\\nSession=\\nIcon=/var/lib/AccountsService/icons/${username}\\nSystemAccount=false\\n"
    "L+ /var/lib/AccountsService/icons/${username}  - - - - ${custom.assets.images.profile.the-seer."512x512"}/share/avatars/the-seer.avatar.512x512.jpg"
  ];
}

{...}: let
  username = "joker9944";
in {
  users = {
    users.${username} = {
      uid = 1000;
      isNormalUser = true;
      group = username;
      homeMode = "750";
      description = "Felix von Arx";
      extraGroups = ["networkmanager" "wheel" "keys" "docker"];
    };

    groups.${username} = {
      gid = 1000;
      members = [username];
    };
  };
}

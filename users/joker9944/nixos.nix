{ ... }:

let
  username = "joker9944";
in {
  users = {
    users.${username} = {
      uid = 1000;
      isNormalUser = true;
      group = username;
      homeMode = "750";
      description = "Felix von Arx";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    groups.${username} = {
      gid = 1000;
      members = [ username ];
    };
  };
}

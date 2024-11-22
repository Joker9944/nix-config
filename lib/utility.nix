lib: with lib; {
  hostsPath = ../hosts;
  modulesPath = ../modules;
  usersPath = ../users;

  listDirs = dir: attrNames ( filterAttrs ( _: type: elem type [ "directory" ] ) ( builtins.readDir dir ));
  listFiles = dir: attrNames ( filterAttrs ( _: type: elem type [ "regular" "symlink" ] ) ( builtins.readDir dir ));

  hostnames = listDirs hostsPath;
  usernames = listDirs usersPath;

  hostsFromUsername = username: nixpkgs.lib.map ( filename: nixpkgs.lib.removeSuffix ".nix" filename ) ( nixpkgs.lib.filter ( filename: filename != "common.nix" ) ( listFiles nixpkgs.lib.path.append usersDir username ));

  hostsByUsers = nixpkgs.lib.listToAttrs ( nixpkgs.lib.map ( username: {
    "name" = username;
    "value" = hostsFromUsername username;
  } ) usernames );

  generateHomeConfiguration = hostname: username:  {
    "${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${nixpkgs.hostPlatform};
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ( nixpkgs.lib.path.append usersDir "${username}/${hostname}.nix" )
      ];
    };
  };

  generateHomeConfigurations = nixpkgs.lib.mergeAttrsList ( nixpkgs.lib.flatten ( nixpkgs.lib.mapAttrsFlatten ( username: hostname: nixpkgs.lib.map ( hostname: generateHomeConfiguration hostname username ) hostnames ) hostsByUsers ));
}

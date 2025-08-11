{
  inputs,
  utility,
  overlays,
  nixosModules,
}: {
  system,
  hostname,
  usernames,
}:
with inputs.nixpkgs.lib; let
  hostsPath = ../hosts;
  usersPath = ../users;

  usersNixosModulePaths = map (username: userNixosModulePath username) usernames;
  userNixosModulePath = username: path.append usersPath "${username}/nixos.nix";
in
  nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs utility;

      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        # TODO find a way to configure this somewhere else
        overlays = overlays;
        config.allowUnfree = true;
      };

      custom = {
        config = {inherit hostname usernames;};

        assets = inputs.nix-assets.packages.${system};
      };
    };

    modules =
      [hostsPath]
      ++ nixosModules
      ++ usersNixosModulePaths
      ++ [
        ({...}: {
          # TODO find a way to configure this somewhere else
          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;
        })
      ];
  }

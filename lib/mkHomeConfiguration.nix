{
  inputs,
  utility,
  overlays,
  homeModules,
}: {
  system,
  username,
  osConfig,
  hostname
}: let
  usersPath = ../users;
in
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${system};

    extraSpecialArgs = {
      inherit inputs utility osConfig;

      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        # TODO find a way to configure this somewhere else
        overlays = overlays;
        config.allowUnfree = true;
      };

      custom = {
        config = {inherit hostname username;};

        assets = inputs.nix-assets.packages.${system};
      };
    };

    modules =
      [usersPath]
      ++ homeModules
      ++ [
        ({...}: {
          # TODO find a way to configure this somewhere else
          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;
        })
      ];
  }

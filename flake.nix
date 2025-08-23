{
  description = "NixOS flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # third party pkgs
    nix-assets = {
      url = "github:joker9944/nix-assets/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    # TODO switch to https://github.com/jalil-salame/audiomenu once https://github.com/jalil-salame/audiomenu/pull/2 is resolved
    audiomenu = {
      url = "github:joker9944/audiomenu/wofi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # helpers
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    sops-nix = {
      url = "github:Mic92/sops-nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland"; # cSpell:ignore hyprwm
    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # libs
    flake-utils.url = "github:numtide/flake-utils/main"; # cSpell:ignore numtide
    nix-math = {
      url = "github:xddxdd/nix-math/master"; # cSpell:ignore xddxdd
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-std.url = "github:chessai/nix-std/master"; # cSpell:ignore chessai
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      nixosModules = [
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (lib.mapAttrsToList (_: value: value) self.nixosModules);

      homeModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.plasma-manager.homeManagerModules.plasma-manager
      ]
      ++ (lib.mapAttrsToList (_: value: value) self.homeModules);

      overlays = [
        inputs.audiomenu.overlays.default
      ]
      ++ lib.mapAttrsToList (_: value: value) self.overlays;

      utility = {
        inherit (inputs.nix-math.lib) math;
        custom = import ./lib/utility.nix lib;
        std = inputs.nix-std.lib;
      };

      mkNixosConfiguration = import ./lib/mkNixosConfiguration.nix {
        inherit
          inputs
          utility
          nixosModules
          overlays
          ;
      };

      mkHomeConfiguration = import ./lib/mkHomeConfiguration.nix {
        inherit
          inputs
          utility
          homeModules
          overlays
          ;
      };
    in
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = utility.custom.applyFunctionRecursive ./pkgs (filename: pkgs.callPackage filename { });

        devShells = {
          default = pkgs.mkShell {
            name = "flake-dev";

            packages = with pkgs; [
              home-manager
              sops
              age
              gnome-tweaks
              dconf-editor
              nodePackages.cspell
            ];
          };

          gitHooks = pkgs.mkShell {
            inherit (self.checks.${system}.preCommitHooksCheck) shellHook;
            buildInputs = self.checks.${system}.preCommitHooksCheck.enabledPackages;
          };
        };

        checks = {
          preCommitHooksCheck = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              trim-trailing-whitespace.enable = true;
              end-of-file-fixer.enable = true;
              fix-byte-order-marker.enable = true;
              mixed-line-endings = {
                enable = true;
                args = [ "--fix=lf" ];
              };
              cspell.enable = true;
              nixfmt-rfc-style.enable = true;
              nil.enable = true;
              statix.enable = true;
            };
          };
        };

        formatter = pkgs.treefmt.withConfig {
          runtimeInputs = [ pkgs.nixfmt-rfc-style ];

          settings = {
            on-unmatched = "info";

            formatter.nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };
          };
        };
      }
    )
    // {
      overlays = {
        firefox-profile-switcher-connector = final: prev: {
          inherit (self.packages.${prev.system}) firefox-profile-switcher-connector;
        };

        "vscode-extensions.streetsidesoftware.code-spell-checker-swiss-german" = final: prev: {
          vscode-extensions =
            lib.attrsets.recursiveUpdate
              (lib.attrsets.optionalAttrs (prev ? vscode-extensions) prev.vscode-extensions)
              {
                streetsidesoftware = {
                  inherit (self.packages.${prev.system}) code-spell-checker-swiss-german;
                };
              };
        };

        "vscode-extensions.blueglassblock.better-json5" = final: prev: {
          vscode-extensions =
            lib.attrsets.recursiveUpdate
              (lib.attrsets.optionalAttrs (prev ? vscode-extensions) prev.vscode-extensions)
              {
                blueglassblock = {
                  inherit (self.packages.${prev.system}) better-json5;
                };
              };
        };

        "vscode-extensions.Weaveworks.vscode-gitops-tools" = final: prev: {
          vscode-extensions =
            lib.attrsets.recursiveUpdate
              (lib.attrsets.optionalAttrs (prev ? vscode-extensions) prev.vscode-extensions)
              {
                Weaveworks = {
                  inherit (self.packages.${prev.system}) vscode-gitops-tools;
                };
              };
        };
      };

      nixosModules = utility.custom.applyFunctionRecursive ./modules/nixos import;
      homeModules = utility.custom.applyFunctionRecursive ./modules/home import;

      nixosConfigurations = lib.attrsets.listToAttrs (
        lib.lists.map
          (cfg: {
            name = cfg.hostname;
            value = mkNixosConfiguration cfg;
          })
          [
            {
              system = "x86_64-linux";
              hostname = "HAL9000";
              usernames = [ "joker9944" ];
              resolution = "2560x1440";
            }
            {
              system = "x86_64-linux";
              hostname = "wintermute";
              usernames = [ "joker9944" ];
              resolution = "3840x2160";
            }
          ]
      );

      homeConfigurations = lib.attrsets.listToAttrs (
        lib.lists.map
          (cfg: {
            name = cfg.username + "@" + cfg.hostname;
            value = mkHomeConfiguration self.nixosConfigurations.${cfg.hostname}.config cfg;
          })
          [
            {
              system = "x86_64-linux";
              hostname = "HAL9000";
              username = "joker9944";
              resolution = "2560x1440";
            }
            {
              system = "x86_64-linux";
              hostname = "wintermute";
              username = "joker9944";
              resolution = "3840x2160";
            }
          ]
      );
    };
}

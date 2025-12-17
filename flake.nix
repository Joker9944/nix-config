{
  description = "NixOS flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    audiomenu = {
      url = "github:jalil-salame/audiomenu/main"; # cSpell: ignore jalil-salame
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # helpers
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nix-jail.url = "sourcehut:~alexdavid/jail.nix"; # cSPell:ignore alexdavid
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      applyFnToDir =
        dir: fn:
        lib.pipe { inherit dir; } [
          self.lib.ls
          (lib.map (path: {
            name = lib.strings.removeSuffix ".nix" (baseNameOf path);
            value = fn path;
          }))
          lib.listToAttrs
        ];
    in
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = applyFnToDir ./pkgs (
          path:
          pkgs.callPackage path {
            jail = inputs.nix-jail.lib.init pkgs;
          }
        );

        apps = {
          cspell = {
            type = "app";
            program = lib.getExe pkgs.nodePackages.cspell;
          };

          dconf-editor = {
            type = "app";
            program = lib.getExe pkgs.dconf-editor;
          };

          gnome-tweaks = {
            type = "app";
            program = lib.getExe pkgs.gnome-tweaks;
          };

          home-manager = {
            type = "app";
            program = lib.getExe pkgs.home-manager;
          };
        };

        devShells = {
          gitHooks = pkgs.mkShell {
            inherit (self.checks.${system}.preCommitHooks) shellHook;
            buildInputs = self.checks.${system}.preCommitHooks.enabledPackages;
          };
        };

        checks = {
          preCommitHooks = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # Files
              trim-trailing-whitespace.enable = true;
              end-of-file-fixer.enable = true;
              fix-byte-order-marker.enable = true;
              mixed-line-endings = {
                enable = true;
                args = [ "--fix=lf" ];
              };

              # General
              cspell.enable = true;

              # Nix
              deadnix.enable = true;
              nil.enable = true;
              nixfmt-rfc-style.enable = true;
              statix.enable = true;

              # Shell
              shellcheck.enable = true;
              shfmt.enable = true;
            };
          };
        };

        formatter =
          let
            inherit (self.checks.${system}.preCommitHooks.config) package configFile;
          in
          pkgs.writeShellScriptBin "pre-commit-run" ''
            ${package}/bin/pre-commit run --all-files --config ${configFile}
          '';
      }
    )
    // {
      overlays = {
        firefox-profile-switcher-connector = _: prev: {
          inherit (self.packages.${prev.system}) firefox-profile-switcher-connector;
        };

        File-MimeInfo = _: prev: {
          inherit (self.packages.${prev.system}) File-MimeInfo;
        };

        freelens = _: prev: {
          inherit (self.packages.${prev.system}) freelens;
        };

        "vscode-extensions.streetsidesoftware.code-spell-checker-swiss-german" = _: prev: {
          vscode-extensions =
            lib.attrsets.recursiveUpdate
              (lib.attrsets.optionalAttrs (prev ? vscode-extensions) prev.vscode-extensions)
              {
                streetsidesoftware = {
                  inherit (self.packages.${prev.system}) code-spell-checker-swiss-german;
                };
              };
        };

        "vscode-extensions.blueglassblock.better-json5" = _: prev: {
          vscode-extensions =
            lib.attrsets.recursiveUpdate
              (lib.attrsets.optionalAttrs (prev ? vscode-extensions) prev.vscode-extensions)
              {
                blueglassblock = {
                  inherit (self.packages.${prev.system}) better-json5;
                };
              };
        };

        "vscode-extensions.Weaveworks.vscode-gitops-tools" = _: prev: {
          vscode-extensions =
            lib.attrsets.recursiveUpdate
              (lib.attrsets.optionalAttrs (prev ? vscode-extensions) prev.vscode-extensions)
              {
                Weaveworks = {
                  inherit (self.packages.${prev.system}) vscode-gitops-tools;
                };
              };
        };

        "vscode-extensions.Grafana.grafana-alloy" = _: prev: {
          vscode-extensions =
            lib.attrsets.recursiveUpdate
              (lib.attrsets.optionalAttrs (prev ? vscode-extensions) prev.vscode-extensions)
              {
                Grafana = {
                  inherit (self.packages.${prev.system}) grafana-alloy;
                };
              };
        };

        # WORKAROUND electron based application only recognize gnome keyring when XDG_CURRENT_DESKTOP is set to GNOME.
        # remove once resolved https://github.com/electron/electron/issues/47436
        element-desktop-gnome-keyring-fix = _: prev: {
          element-desktop = prev.element-desktop.overrideAttrs (
            _: previousAttrs: {
              desktopItem = previousAttrs.desktopItem.override {
                exec = "element-desktop --password-store=gnome-libsecret %u"; # cSpell:words libsecret
              };
            }
          );
        };
      };

      nixConfig = {
        substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
        ];

        trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # cSpell:disable-line
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" # cSpell:disable-line
        ];
      };

      nixosModules = applyFnToDir ./modules/nixos import;

      homeModules = applyFnToDir ./modules/home import;

      lib = import ./lib {
        inherit lib inputs;

        nixosModules = lib.attrValues self.nixosModules;
        overlays = lib.attrValues self.overlays;
        homeModules = lib.attrValues self.homeModules;

        custom = {
          inherit (inputs.nix-math.lib) math;
          std = inputs.nix-std.lib;
        };
      };

      nixosConfigurations =
        lib.pipe
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
          [
            (lib.map (cfg: {
              name = cfg.hostname;
              value = self.lib.mkNixosConfiguration cfg;
            }))
            lib.listToAttrs
          ];

      homeConfigurations =
        lib.pipe
          [
            {
              hostname = "HAL9000";
              username = "joker9944";
            }
            {
              hostname = "wintermute";
              username = "joker9944";
            }
          ]
          [
            (lib.map (cfg: {
              name = cfg.username + "@" + cfg.hostname;
              value = self.lib.mkHomeConfiguration {
                nixosConfigurations = self.nixosConfigurations.${cfg.hostname};
              } cfg;
            }))
            lib.listToAttrs
          ];
    };
}

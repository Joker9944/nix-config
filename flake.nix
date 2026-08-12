{
  description = "NixOS flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # HACK(pedantic-borg) Hyprland had a regression where release binds are firing even when matching other binds, locked until fixed.
    # Also had to downgrade further since v0.56.2 release was broken.
    # https://github.com/hyprwm/Hyprland/discussions/15066 krank:ignore-line
    # https://github.com/hyprwm/Hyprland/issues/15568#issuecomment-5230819813
    hyprland.url = "github:hyprwm/Hyprland/v0.56.1"; # cSpell:ignore hyprwm

    # home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # third party packages
    nix-assets = {
      url = "github:joker9944/nix-assets/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    audiomenu = {
      url = "github:jalil-salame/audiomenu/main"; # cSpell:ignore jalil-salame
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yas = {
      url = ./apps/yas;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official"; # cSpell:ignore anthropics
      flake = false;
    };
    claude-okf-skills = {
      url = "github:scaccogatto/okf-skills"; # cSpell:ignore scaccogatto
      flake = false;
    };

    # modules
    sops-nix = {
      url = "github:Mic92/sops-nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-which-key = {
      url = "github:alexwforsythe/tmux-which-key"; # cSpell:ignore alexwforsythe
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # helpers
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils/main"; # cSpell:ignore numtide
    nix-jail.url = "sourcehut:~alexdavid/jail.nix"; # cSPell:ignore alexdavid
    nix-schemes = {
      url = ./apps/nix-schemes;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # libs
    nix-math = {
      url = "github:xddxdd/nix-math/master"; # cSpell:ignore xddxdd
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
    in
    lib.recursiveUpdate
      (inputs.flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = import ./pkgs {
            inherit lib pkgs inputs;
            flake = self;
          };

          apps = import ./apps.nix { inherit lib pkgs system; };

          devShells = {
            default = pkgs.mkShell {
              buildInputs = [
                self.packages.${system}.hm-options
                self.packages.${system}.nixos-options
              ];
            };
            preCommitHooks = pkgs.mkShell {
              inherit (self.checks.${system}.preCommitHooks) shellHook;
              buildInputs = self.checks.${system}.preCommitHooks.enabledPackages;
            };
            nx =
              (pkgs.buildFHSEnv {
                name = "nx-dev";
                targetPkgs =
                  pkgs: with pkgs; [
                    bash
                    git
                    nodejs
                  ];
              }).env;
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

                # Nix
                deadnix.enable = true;
                nil.enable = true;
                nixfmt.enable = true;
                statix.enable = true;

                # Links
                rewrite-pr-links = {
                  enable = true;
                  name = "rewrite-pr-links";
                  description = "Rewrites GitHub pull request links to their issue form so krank can read them";
                  entry = lib.getExe (
                    pkgs.writeShellApplication {
                      name = "rewrite-pr-links";

                      text = ''
                        sed -i -E 's|(github\.com/[^/ ]+/[^/ ]+)/pull/([0-9]+)|\1/issues/\2|g' "$@"
                      '';

                      runtimeInputs = [ pkgs.gnused ];
                    }
                  );
                  files = "\\.nix$";
                  language = "system";
                };

                # Shell
                shellcheck = {
                  enable = true;
                  excludes = [
                    "^nx(\\..+)?$"
                    ".envrc"
                  ];
                };
                shfmt.enable = true;

                # Python
                ruff.enable = true;
                ruff-format.enable = true;
              };
            };

            libTests = pkgs.callPackage ./tests/lib { flake = self; };
          };

          formatter =
            let
              inherit (self.checks.${system}.preCommitHooks.config) package configFile;
            in
            pkgs.writeShellScriptBin "pre-commit-run" ''
              ${package}/bin/pre-commit run --all-files --config ${configFile}
            '';
        }
      ))
      {
        overlays = import ./overlays.nix { flake = self; };

        nixosModules = {
          default = lib.modules.importApply ./modules/nixos { flake = self; };
        };

        homeModules = {
          default = lib.modules.importApply ./modules/home { flake = self; };
        };

        lib = import ./lib {
          inherit lib inputs;

          flake = self;

          custom = {
            inherit (inputs.nix-math.lib) math;
          };
        };

        nixosConfigurations =
          lib.pipe
            [
              {
                system = "x86_64-linux";
                hostname = "HAL9000";
                profile = "hyprland-desktop";
                usernames = [ "joker9944" ];
                resolution = "2560x1440";
              }
              {
                system = "x86_64-linux";
                hostname = "wintermute";
                profile = "hyprland-desktop";
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

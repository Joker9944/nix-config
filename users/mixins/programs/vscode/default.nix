{
  inputs,
  lib,
  pkgs-unstable,
  config,
  ...
}:
{
  options.mixins.programs.vscode =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "vscode config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.vscode;

      vscodePackage = pkgs-unstable.vscodium.fhsWithPackages (
        ps: with ps; [
          sops # default -> used for git secret encryption
          fluxcd # k8s -> vscode-gitops-tools extension
          grafana-alloy # k8s -> grafana-alloy extension
          texliveFull # quarto -> quarto extension
          # WORKAROUND In a FHS files are either owned by the user or nobody since the ssh config
          # is linked into the user home from the nix store meaning the file is owner by root outside
          # of the FHS and by nobody in the FHS. This leads openssh to complain about insecure ssh
          # config ownership which is actually fine. So let's just disable the check.
          # https://github.com/nix-community/home-manager/issues/322#issuecomment-1454284183
          (ps.openssh.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [ ./openssh-no-checkperm.patch ]; # cSpell:ignore checkperm
          }))
        ]
      );

      nixpkgs-vscode-extensions = pkgs-unstable.vscode-extensions;

      vscodeExtensions =
        inputs.nix-vscode-extensions.extensions.${pkgs-unstable.stdenv.hostPlatform.system}.forVSCodeVersion
          vscodePackage.version;

      inherit (vscodeExtensions) open-vsx-release;

      commonProfiles = [
        {
          userSettings = {
            "diffEditor.ignoreTrimWhitespace" = false;
            "editor.fontFamily" = "monospace, emoji";
            "editor.renderWhitespace" = "boundary";
            "editor.tabSize" = 2;
            "files.autoSave" = "afterDelay";
            "files.insertFinalNewline" = true;
            "files.trimFinalNewlines" = true;
            "git.path" = lib.getExe config.programs.git.package;
            "git.enableCommitSigning" = true;
            "git.defaultCloneDirectory" = "~/Workspace";
            "git.confirmSync" = false;
            "git.blame.editorDecoration.enabled" = true;
            "git.autofetch" = true; # cSpell:ignore autofetch
            "telemetry.feedback.enabled" = false;
          };
        }
        {
          extensions = [
            open-vsx-release.k--kato.intellij-idea-keybindings # cSpell:words k--kato
          ];
        }
        {
          extensions = [
            open-vsx-release.dracula-theme.theme-dracula
          ];

          userSettings."workbench.colorTheme" = "Dracula Theme";
        }
        {
          extensions = [
            open-vsx-release.streetsidesoftware.code-spell-checker
          ];
        }
        {
          extensions = [
            open-vsx-release.editorconfig.editorconfig
          ];
        }
        {
          extensions = [
            open-vsx-release.esbenp.prettier-vscode # cSpell:words esbenp
          ];

          userSettings =
            lib.pipe
              [
                "markdown"
                "json"
                "jsonc"
                "yaml"
                "typescript"
                "typescriptreact"
                "scss"
              ]
              [
                (lib.map (filetype: "[${filetype}]"))
                (lib.map (filetype: {
                  name = filetype;
                  value = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
                  };
                }))
                lib.listToAttrs
              ];
        }
        {
          extensions = [
            open-vsx-release.blueglassblock.better-json5
          ];

          userSettings = {
            "[json5]" = {
              "editor.defaultFormatter" = "BlueGlassBlock.better-json5";
            };
          };
        }
        {
          extensions = [
            open-vsx-release.mkhl.shfmt # cSpell:ignore mkhl
          ];
        }
        {
          extensions = [
            open-vsx-release.timonwong.shellcheck # cSpell:ignore timonwong
          ];
        }
      ];

      mergeProfiles =
        lib.foldl
          (
            acc: el:
            lib.recursiveUpdate acc el
            // {
              extensions = acc.extensions ++ el.extensions or [ ];
            }
          )
          {
            extensions = [ ];
            userSettings = { };
          };

      mkProfile =
        profiles:
        if lib.isList profiles then
          mergeProfiles (commonProfiles ++ profiles)
        else
          mergeProfiles (commonProfiles ++ [ profiles ]);
    in
    lib.mkIf cfg.enable {
      programs = {
        bash.shellAliases.code = "codium";

        vscode = {
          enable = true;
          package = vscodePackage;

          profiles = {
            default = mkProfile {
              enableUpdateCheck = false;
              enableExtensionUpdateCheck = false;
            };

            nix = mkProfile [
              {
                extensions = [
                  open-vsx-release.jnoortheen.nix-ide # cSpell:words jnoortheen
                ];

                userSettings = {
                  "nix.enableLanguageServer" = true;
                  "nix.serverPath" = lib.getExe pkgs-unstable.nil;
                  "nix.serverSettings" = {
                    nil.formatting.command = [ (lib.getExe pkgs-unstable.nixfmt) ];
                    nix.flake = {
                      autoArchive = true;
                      autoEvalInputs = true;
                    };
                  };
                  "[nix]" = {
                    "editor.tabSize" = 2;
                  };
                };
              }
            ];

            notes = mkProfile [
              {
                extensions = [
                  open-vsx-release.foam.foam-vscode
                  open-vsx-release.yzhang.markdown-all-in-one # cSpell:words yzhang
                ];
              }
            ];

            quarto = mkProfile [
              {
                extensions = [
                  open-vsx-release.quarto.quarto
                ];

                userSettings = {
                  "quarto.path" = lib.getExe pkgs-unstable.quarto;
                };
              }
            ];

            k8s = mkProfile [
              {
                extensions = [
                  open-vsx-release.ms-kubernetes-tools.vscode-kubernetes-tools
                  nixpkgs-vscode-extensions.ms-vscode-remote.remote-containers
                  open-vsx-release.weaveworks.vscode-gitops-tools
                  open-vsx-release.grafana.grafana-alloy
                ];

                userSettings = {
                  "vs-kubernetes" = {
                    "vs-kubernetes.crd-code-completion" = "enabled";
                    "vs-kubernetes.kubectl-path" = lib.getExe pkgs-unstable.kubectl;
                    "vs-kubernetes.helm-path" = lib.getExe pkgs-unstable.kubernetes-helm;
                  };
                };
              }
              {
                extensions = [
                  open-vsx-release.redhat.vscode-yaml
                ];

                userSettings = {
                  "redhat.telemetry.enabled" = false;
                  "[yaml]" = {
                    "editor.defaultFormatter" = "redhat.vscode-yaml";
                  };
                };
              }
            ];
          };
        };
      };
    };
}

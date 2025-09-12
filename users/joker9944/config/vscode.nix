{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  inherit (pkgs) vscode-extensions;

  commonProfiles = [
    {
      # vscode settings
      userSettings = {
        "diffEditor.ignoreTrimWhitespace" = false;
        "editor.fontFamily" = "monospace, emoji";
        "editor.renderWhitespace" = "boundary";
        "editor.tabSize" = 2;
        "files.autoSave" = "afterDelay";
        "files.insertFinalNewline" = true;
        "git.confirmSync" = false;
        "git.blame.editorDecoration.enabled" = true;
        "git.autofetch" = true; # cSpell:ignore autofetch
      };
    }
    {
      extensions = [
        vscode-extensions.dracula-theme.theme-dracula
      ];

      userSettings."workbench.colorTheme" = "Dracula Theme";
    }
    {
      extensions = [
        vscode-extensions.streetsidesoftware.code-spell-checker
      ];
    }
    {
      extensions = [
        vscode-extensions.esbenp.prettier-vscode # cSpell:words esbenp
      ];

      userSettings = {
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      };
    }
    {
      extensions = [
        vscode-extensions.blueglassblock.better-json5
      ];

      userSettings = {
        "[json5]" = {
          "editor.defaultFormatter" = "BlueGlassBlock.better-json5";
        };
      };
    }
    {
      extensions = [
        vscode-extensions.k--kato.intellij-idea-keybindings # cSpell:words k--kato
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
{
  config = {
    home.packages = with pkgs; [
      sops # default -> used for git secret encryption
      pre-commit # default -> used for git pre commit checks
      nixfmt-rfc-style # nix -> formatter
      nil # nix -> language server
      kubectl # k8s -> vscode-kubernetes-tools extension
      kubernetes-helm # k8s -> vscode-kubernetes-tools extension
      fluxcd # k8s -> vscode-gitops-tools extension
    ];

    programs.vscode = {
      package = pkgs-unstable.vscodium;

      profiles = {
        default = mkProfile {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
        };

        nix = mkProfile [
          {
            extensions = [
              vscode-extensions.jnoortheen.nix-ide # cSpell:words jnoortheen
            ];

            userSettings = {
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nil";
              "nix.serverSettings" = {
                nil.formatting.command = [ "nixfmt" ];
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
            extensions = with vscode-extensions; [
              foam.foam-vscode
              yzhang.markdown-all-in-one # cSpell:words yzhang
            ];
          }
        ];

        k8s = mkProfile [
          {
            extensions = with vscode-extensions; [
              ms-kubernetes-tools.vscode-kubernetes-tools
              ms-vscode-remote.remote-containers
              Weaveworks.vscode-gitops-tools
            ];

            userSettings = {
              "vs-kubernetes" = {
                "vs-kubernetes.crd-code-completion" = "enabled";
              };
            };
          }
          {
            extensions = [
              vscode-extensions.redhat.vscode-yaml
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
}

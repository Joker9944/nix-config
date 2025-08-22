{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  vscodeExtensions = pkgs.vscode-extensions;

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
        "git.autofetch" = true;
      };
    }
    {
      extensions = [
        vscodeExtensions.dracula-theme.theme-dracula
      ];

      userSettings."workbench.colorTheme" = "Dracula Theme";
    }
    {
      extensions = with vscodeExtensions.streetsidesoftware; [
        code-spell-checker
        code-spell-checker-swiss-german
      ];

      userSettings."cSpell.language" = "en,de-CH";
    }
    {
      extensions = [
        vscodeExtensions.esbenp.prettier-vscode
      ];

      userSettings = {
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      };
    }
    {
      extensions = [
        vscodeExtensions.blueglassblock.better-json5
      ];

      userSettings = {
        "[json5]" = {
          "editor.defaultFormatter" = "BlueGlassBlock.better-json5";
        };
      };
    }
    {
      extensions = [
        vscodeExtensions.k--kato.intellij-idea-keybindings
      ];
    }
  ];

  mergeProfiles = profiles:
    lib.lists.foldr (el: acc:
      (lib.attrsets.recursiveUpdate acc el)
      // {
        extensions = acc.extensions ++ (el.extensions or []);
      }) {
      extensions = [];
      userSettings = {};
    }
    profiles;

  mkProfile = profiles:
    if lib.lists.isList profiles
    then mergeProfiles (commonProfiles ++ profiles)
    else mergeProfiles (commonProfiles ++ [profiles]);
in {
  config = {
    home.packages = with pkgs; [
      sops # default -> used for git secret encryption
      pre-commit # default -> used for git pre commit checks
      alejandra # nix -> alejandra extension
      nil # nix -> nix language server
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
              vscodeExtensions.jnoortheen.nix-ide
            ];

            userSettings = {
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nil";
              "[nix]" = {
                "editor.tabSize" = 2;
              };
            };
          }
          {
            extensions = [
              vscodeExtensions.kamadorueda.alejandra
            ];

            userSettings = {
              "alejandra.program" = "alejandra";
              "[nix]" = {
                "editor.defaultFormatter" = "kamadorueda.alejandra";
                "editor.formatOnPaste" = true;
                "editor.formatOnSave" = true;
                "editor.formatOnType" = false;
              };
            };
          }
        ];

        notes = mkProfile {
          extensions = with vscodeExtensions; [
            foam.foam-vscode
            yzhang.markdown-all-in-one
          ];
        };

        k8s = mkProfile [
          {
            extensions = with vscodeExtensions; [
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
              vscodeExtensions.redhat.vscode-yaml
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

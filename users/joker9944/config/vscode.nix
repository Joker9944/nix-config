{
  lib,
  pkgs,
  ...
}: let
  commonProfiles = [
    {
      # vscode settings
      userSettings = {
        "diffEditor.ignoreTrimWhitespace" = false;
        "editor.fontFamily" = "'JetBrains Mono', 'Adwaita Mono', monospace";
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
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
      ];

      userSettings."workbench.colorTheme" = "Dracula Theme";
    }
    {
      extensions = with pkgs.vscode-extensions; [
        streetsidesoftware.code-spell-checker
        streetsidesoftware.code-spell-checker-swiss-german
      ];

      userSettings."cSpell.language" = "en,de-CH";
    }
    {
      extensions = with pkgs.vscode-extensions; [
        esbenp.prettier-vscode
      ];

      userSettings = {
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      };
    }
    {
      extensions = with pkgs.vscode-extensions; [
        k--kato.intellij-idea-keybindings
      ];
    }
  ];

  mergeProfiles = profiles:
    lib.lists.foldr (el: acc:
      (lib.recursiveUpdate acc el)
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
      jetbrains-mono # default -> font configured
      sops # default -> used for git secret encryption
      alejandra # nix -> alejandra extension
      kubectl # k8s -> kubernetes tooling
      helm # k8s -> kubernetes tooling
    ];

    programs.vscode = {
      package = pkgs.vscodium;

      profiles = {
        default = mkProfile {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
        };

        nix = mkProfile [
          {
            extensions = with pkgs.vscode-extensions; [
              jnoortheen.nix-ide
            ];

            userSettings = {
              "[nix]" = {
                "editor.tabSize" = 2;
              };
            };
          }
          {
            extensions = with pkgs.vscode-extensions; [
              kamadorueda.alejandra
            ];

            userSettings = {
              "[nix]" = {
                "editor.defaultFormatter" = "kamadorueda.alejandra";
                "editor.formatOnPaste" = true;
                "editor.formatOnSave" = true;
                "editor.formatOnType" = false;
              };
              "alejandra.program" = "alejandra";
            };
          }
        ];

        notes = mkProfile {
          extensions = with pkgs.vscode-extensions; [
            foam.foam-vscode
            yzhang.markdown-all-in-one
          ];
        };

        k8s = mkProfile [
          {
            extensions = with pkgs.vscode-extensions; [
              ms-kubernetes-tools.vscode-kubernetes-tools
              ms-vscode-remote.remote-containers
            ];
          }
          {
            extensions = with pkgs.vscode-extensions; [
              redhat.vscode-yaml
            ];

            userSettings = {
              "redhat.telemetry.enabled" = false;
            };
          }
        ];
      };
    };
  };
}

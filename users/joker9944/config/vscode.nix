{
  lib,
  pkgs,
  ...
}: let
  commonExtensions = with pkgs.vscode-extensions; [
    dracula-theme.theme-dracula
    streetsidesoftware.code-spell-checker
    streetsidesoftware.code-spell-checker-swiss-german
    esbenp.prettier-vscode
  ];

  commonSettings = {
    "files.autoSave" = "afterDelay";
    "files.insertFinalNewline" = true;
    "editor.tabSize" = 2;
    "editor.renderWhitespace" = "boundary";
    "diffEditor.ignoreTrimWhitespace" = false;
    "workbench.colorTheme" = "Dracula Theme";
    "editor.fontFamily" = "'JetBrains Mono', 'Adwaita Mono', monospace";
    "[markdown]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "cSpell.language" = "en,de-CH";
    "git.confirmSync" = false;
  };

  mkProfile = profile:
    profile
    // {
      extensions = commonExtensions ++ profile.extensions or [];
      userSettings = lib.recursiveUpdate commonSettings profile.userSettings or {};
    };
in {
  config.programs.vscode = {
    package = pkgs.vscodium;

    profiles = {
      default = mkProfile {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
      };

      nix = mkProfile {
        extensions = with pkgs.vscode-extensions; [
          kamadorueda.alejandra
          jnoortheen.nix-ide
        ];

        userSettings = {
          "[nix]" = {
            "editor.tabSize" = 2;
          };
        };
      };

      notes = mkProfile {
        extensions = with pkgs.vscode-extensions; [
          foam.foam-vscode
          yzhang.markdown-all-in-one
        ];
      };

      k8s = mkProfile {
        extensions = with pkgs.vscode-extensions; [
          ms-kubernetes-tools.vscode-kubernetes-tools
          ms-vscode-remote.remote-containers
          redhat.vscode-yaml
        ];

        userSettings = {
          "redhat.telemetry.enabled" = false;
        };
      };
    };
  };
}

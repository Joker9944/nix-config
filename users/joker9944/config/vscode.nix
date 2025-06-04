{pkgs, ...}: let
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
    "[markdown]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "cSpell.language" = "en,de-CH";
  };
in {
  config.programs.vscode = {
    package = pkgs.vscodium;

    profiles = {
      default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        extensions = commonExtensions;

        userSettings = commonSettings;
      };
      nix = {
        extensions = with pkgs.vscode-extensions;
          [
            kamadorueda.alejandra
            jnoortheen.nix-ide
          ]
          ++ commonExtensions;

        userSettings =
          {
            "[nix]" = {
              "editor.tabSize" = 2;
            };
          }
          // commonSettings;
      };
      notes = {
        extensions = with pkgs.vscode-extensions;
          [
            foam.foam-vscode
            yzhang.markdown-all-in-one
          ]
          ++ commonExtensions;

        userSettings = commonSettings;
      };
    };
  };
}

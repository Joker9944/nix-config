{ inputs, mkMixinModule, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";

    runtimeInputs = with pkgs; [
      jq
      coreutils
    ];

    text = builtins.readFile ./files/statusline.sh;
  };
in
mkMixinModule "claude-code" {
  programs.claude-code = {
    enable = true;

    context = ./files/CLAUDE.md;

    enableMcpIntegration = lib.mkDefault config.programs.mcp.enable;

    # Setting `settings` at all makes `~/.claude/settings.json` a read-only store symlink, so
    # everything `/config` and `/model` would otherwise persist has to live here too.
    settings = {
      model = "opus";
      effortLevel = "xhigh";
      tui = "fullscreen";
      skipAutoPermissionPrompt = true;

      statusLine = {
        type = "command";
        command = lib.getExe statusline;
        # The reset countdowns are time-based; event-driven updates stall while the session idles.
        refreshInterval = 60;
      };
    };

    plugins = [
      "${inputs.claude-plugins-official}/plugins/skill-creator"
      "${inputs.claude-plugins-official}/plugins/code-review"
      "${inputs.claude-okf-skills}"
    ];

    lspServers = {
      nix = {
        command = lib.getExe pkgs.nil;
        extensionToLanguage.".nix" = "nix";
      };

      haskell = {
        command = lib.getExe' pkgs.haskellPackages.haskell-language-server "haskell-language-server-wrapper";
        args = [ "--lsp" ];
        extensionToLanguage = {
          ".hs" = "haskell";
          ".lhs" = "haskell";
        };
      };

      typescript = {
        args = [
          "--stdio"
        ];
        command = lib.getExe pkgs.typescript-language-server;
        extensionToLanguage = {
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
        };
      };
    };
  };
}

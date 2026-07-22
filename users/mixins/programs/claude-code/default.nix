{ mkMixinModule, ... }:
{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
mkMixinModule "claude-code" {
  programs.claude-code = {
    enable = true;

    context = ./files/CLAUDE.md;

    enableMcpIntegration = lib.mkDefault config.programs.mcp.enable;

    plugins = [
      "${inputs.claude-plugins-official}/plugins/skill-creator"
      "${inputs.claude-plugins-official}/plugins/code-review"
      "${inputs.claude-okf-skills}"
    ];

    lspServers.nix = {
      command = lib.getExe pkgs.nil;
      extensionToLanguage.".nix" = "nix";
    };
  };
}

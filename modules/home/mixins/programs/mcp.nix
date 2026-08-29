{ mkMixinModule, ... }:
{ lib, pkgs, ... }:
mkMixinModule "mcp" {
  programs.mcp = {
    enable = true;

    servers = {
      nix.command = lib.getExe pkgs.mcp-nixos;
    };
  };
}

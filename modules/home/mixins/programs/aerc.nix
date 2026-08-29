{ mkMixinModule, ... }:
{ lib, pkgs, ... }:
mkMixinModule "aerc" {
  programs.aerc = {
    extraConfig = {
      viewer.pager = "${lib.getExe pkgs.moor} --no-statusbar --no-linenumbers";

      ui = {
        icon-encrypted = "✔";
        icon-signed = "✔";
        icon-signed-encrypted = "✔";
        icon-unknown = "✘";
        icon-invalid = "⚠";
      };
    };

    extraBinds = {
      messages = {
        q = ":quit<Enter>";
      };
    };
  };
}

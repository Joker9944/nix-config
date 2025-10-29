{ lib, pkgs, ... }:
{
  programs.yazi.settings.opener.open = [
    {
      desc = "Open";
      run = "xdg-open \"$1\"";
      for = "linux";
    }
    {
      desc = "Open with";
      run = "clear; ${lib.getExe pkgs.File-MimeInfo} --ask \"$1\"";
      block = true;
      for = "linux";
    }
  ];
}

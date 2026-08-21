{ pkgs, flakeLib, ... }:
let
  signal = {
    name = "signal-desktop-8.21.0";
    desktopItems = [ { name = "signal.desktop"; } ];
  };
in
{
  testRequireDesktopFileExplicitName = {
    expr = flakeLib.requireDesktopFile {
      inherit pkgs;
      package = signal;
      name = "signal.desktop";
    };
    expected = "signal.desktop";
  };

  testRequireDesktopFileDefaultName = {
    expr = flakeLib.requireDesktopFile {
      inherit pkgs;
      package = {
        name = "vesktop-1.6.5";
        desktopItems = [ { name = "vesktop.desktop"; } ];
      };
    };
    expected = "vesktop.desktop";
  };

  # `copyDesktopItems` accepts a bare item as well as a list
  testRequireDesktopFileBareItem = {
    expr = flakeLib.requireDesktopFile {
      inherit pkgs;
      package = {
        name = "vdu-controls-2.0.0";
        desktopItems = {
          name = "vdu_controls.desktop";
        };
      };
      name = "vdu_controls.desktop";
    };
    expected = "vdu_controls.desktop";
  };

  testRequireDesktopFileMissing = {
    expr =
      (builtins.tryEval (
        flakeLib.requireDesktopFile {
          inherit pkgs;
          package = signal;
        }
      )).success;
    expected = false;
  };

  # A package declaring no `desktopItems` is checked when the entry ID is built into a file
  testRequireDesktopFileUndeclared = {
    expr =
      let
        entry = flakeLib.requireDesktopFile {
          inherit pkgs;
          package = pkgs.hello;
          name = "hello.desktop";
        };
      in
      {
        id = entry;
        checked = builtins.getContext entry != { };
      };
    expected = {
      id = "hello.desktop";
      checked = true;
    };
  };
}

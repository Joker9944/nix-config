{ flakeLib, ... }:
let
  signal = {
    name = "signal-desktop-8.21.0";
    desktopItems = [ { name = "signal.desktop"; } ];
  };
in
{
  testRequireDesktopFileExplicitName = {
    expr = flakeLib.requireDesktopFile {
      package = signal;
      name = "signal.desktop";
    };
    expected = "signal.desktop";
  };

  testRequireDesktopFileDefaultName = {
    expr = flakeLib.requireDesktopFile {
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
    expr = (builtins.tryEval (flakeLib.requireDesktopFile { package = signal; })).success;
    expected = false;
  };
}

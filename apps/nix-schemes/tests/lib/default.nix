{
  lib,
  pkgs,
  flake,
  ...
}:
let
  # Initialize libSchemes with pkgs for impure functions
  libSchemes = flake.lib.init pkgs;

  # Collect all test suites from lib/
  libTests = lib.pipe ./. [
    builtins.readDir
    lib.attrNames
    (lib.map (filename: lib.path.append ./. filename))
    (lib.filter (path: path != ./default.nix))
    (lib.map (path: import path { inherit lib libSchemes; }))
    lib.mergeAttrsList
  ];

  # Run all tests and collect failures
  failures = lib.runTests libTests;

  # Format failure message
  formatFailure = failure: ''
    FAIL: ${failure.name}
      expected: ${lib.generators.toPretty { } failure.expected}
      actual:   ${lib.generators.toPretty { } failure.result}
  '';

  failureMessage = lib.concatMapStringsSep "\n" formatFailure failures;
in
pkgs.runCommand "lib-tests"
  {
    passthru = {
      inherit failures libTests;
    };
  }
  (
    if failures == [ ] then
      ''
        echo "All ${toString (lib.length (lib.attrNames libTests))} tests passed"
        touch $out
      ''
    else
      ''
        echo "Test failures:"
        echo ""
        echo "${failureMessage}"
        echo ""
        echo "${toString (lib.length failures)} test(s) failed"
        exit 1
      ''
  )

{
  lib,
  pkgs,
  flake,
  ...
}:
let
  flakeLib = flake.lib;

  # Collect all test suites from lib/
  libTests =
    lib.pipe
      {
        dir = ./.;
        exclude = [ ./default.nix ];
      }
      [
        flakeLib.ls
        (lib.map (path: import path { inherit lib flakeLib; }))
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

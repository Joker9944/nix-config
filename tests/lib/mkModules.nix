{ flakeLib, ... }:
let
  inherit (flakeLib.modules) mkModules;

  collect = mkModules {
    prefix = "p";
    dir = ../fixtures/mkModules;
  };
in
{
  testKeysMirrorPathSegments = {
    expr = builtins.attrNames collect;
    expected = [
      "p-folder"
      "p-leaf"
      "p-namespace-deep"
      "p-namespace-nested"
    ];
  };

  testBarePathWithoutArgs = {
    expr = builtins.isPath collect.p-leaf;
    expected = true;
  };

  testArgsAreApplied = {
    expr =
      builtins.isAttrs
        (mkModules {
          prefix = "p";
          dir = ../fixtures/mkModules;
          args = { };
        }).p-leaf;
    expected = true;
  };

  testExcludeDropsEntry = {
    expr = builtins.attrNames (mkModules {
      prefix = "p";
      dir = ../fixtures/mkModules;
      exclude = [ ../fixtures/mkModules/leaf.nix ];
    });
    expected = [
      "p-folder"
      "p-namespace-deep"
      "p-namespace-nested"
    ];
  };

  testDuplicateNamesThrow = {
    expr =
      (builtins.tryEval (
        builtins.attrNames (mkModules {
          prefix = "p";
          dir = ../fixtures/mkModulesCollision;
        })
      )).success;
    expected = false;
  };
}

{ flakeLib, ... }:
let
  inherit (flakeLib.modules) mkClassModule;

  nixosBranch = {
    services.foo.enable = true;
  };
  homeBranch = {
    programs.foo.enable = true;
  };

  both = {
    nixos = nixosBranch;
    homeManager = homeBranch;
  };
in
{
  testSelectsNixosBranch = {
    expr = (mkClassModule "nixos" both).imports;
    expected = [ nixosBranch ];
  };

  testSelectsHomeManagerBranch = {
    expr = (mkClassModule "homeManager" both).imports;
    expected = [ homeBranch ];
  };

  testMissingClassIsNoop = {
    expr = (mkClassModule "nixos" { homeManager = homeBranch; }).imports;
    expected = [ ];
  };

  testNullClassIsNoop = {
    expr = (mkClassModule null both).imports;
    expected = [ ];
  };

  testNonClassKeyThrows = {
    expr = (builtins.tryEval (mkClassModule "nixos" { home = homeBranch; })).success;
    expected = false;
  };
}

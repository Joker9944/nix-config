{ flakeLib, ... }:
let
  enabled = flakeLib.mkMixinModule {
    config.mixins.programs.foo.enable = true;
    prefix = [ "programs" ];
  };

  disabled = flakeLib.mkMixinModule {
    config.mixins.programs.foo.enable = false;
    prefix = [ "programs" ];
  };

  toplevel = flakeLib.mkMixinModule {
    config.mixins.bar.enable = true;
  };

  result = enabled "foo" { services.foo.enable = true; };
in
{
  testDeclaresEnableOptionAtPrefixedPath = {
    expr = result.options.mixins.programs.foo.enable._type;
    expected = "option";
  };

  testGatesConfigOnEnable = {
    expr = (enabled "foo" { services.foo.enable = true; }).config.condition;
    expected = true;
  };

  testConfigDisabledWhenFlagOff = {
    expr = (disabled "foo" { services.foo.enable = true; }).config.condition;
    expected = false;
  };

  testGatedConfigContentPreserved = {
    expr = result.config.content.services.foo.enable;
    expected = true;
  };

  testEmptyPrefixDeclaresTopLevelOption = {
    expr = (toplevel "bar" { services.bar.enable = true; }).options.mixins.bar.enable._type;
    expected = "option";
  };
}

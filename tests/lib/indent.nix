{ flakeLib, ... }:
{
  # mkIndentPrefix tests
  testMkIndentPrefixZero = {
    expr = flakeLib.mkIndentPrefix 0;
    expected = "";
  };

  testMkIndentPrefixOne = {
    expr = flakeLib.mkIndentPrefix 1;
    expected = " ";
  };

  testMkIndentPrefixFour = {
    expr = flakeLib.mkIndentPrefix 4;
    expected = "    ";
  };

  # indent tests
  testIndentZero = {
    expr = flakeLib.indent 0 "hello";
    expected = "hello";
  };

  testIndentTwo = {
    expr = flakeLib.indent 2 "hello";
    expected = "  hello";
  };

  testIndentFour = {
    expr = flakeLib.indent 4 "world";
    expected = "    world";
  };

  # indentLines tests
  testIndentLinesSingle = {
    expr = flakeLib.indentLines 2 "hello";
    expected = "  hello";
  };

  testIndentLinesMultiple = {
    expr = flakeLib.indentLines 2 "line1\nline2\nline3";
    expected = "  line1\n  line2\n  line3";
  };

  testIndentLinesEmpty = {
    expr = flakeLib.indentLines 2 "";
    expected = "  ";
  };
}

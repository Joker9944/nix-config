{ libUtil, ... }:
{
  # mkIndentPrefix tests
  testMkIndentPrefixZero = {
    expr = libUtil.strings.mkIndentPrefix 0;
    expected = "";
  };

  testMkIndentPrefixOne = {
    expr = libUtil.strings.mkIndentPrefix 1;
    expected = " ";
  };

  testMkIndentPrefixFour = {
    expr = libUtil.strings.mkIndentPrefix 4;
    expected = "    ";
  };

  # indent tests
  testIndentZero = {
    expr = libUtil.strings.indent 0 "hello";
    expected = "hello";
  };

  testIndentTwo = {
    expr = libUtil.strings.indent 2 "hello";
    expected = "  hello";
  };

  testIndentFour = {
    expr = libUtil.strings.indent 4 "world";
    expected = "    world";
  };

  # indentLines tests
  testIndentLinesSingle = {
    expr = libUtil.strings.indentLines 2 "hello";
    expected = "  hello";
  };

  testIndentLinesMultiple = {
    expr = libUtil.strings.indentLines 2 "line1\nline2\nline3";
    expected = "  line1\n  line2\n  line3";
  };

  testIndentLinesEmpty = {
    expr = libUtil.strings.indentLines 2 "";
    expected = "  ";
  };
}

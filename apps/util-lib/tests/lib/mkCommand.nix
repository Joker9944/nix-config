{ libUtil, ... }:
{
  testMkCommandSimple = {
    expr = libUtil.strings.mkCommand [
      "echo"
      "hello"
    ];
    expected = "echo hello";
  };

  testMkCommandNested = {
    expr = libUtil.strings.mkCommand [
      "cmd"
      [
        "--flag"
        "value"
      ]
      "arg"
    ];
    expected = "cmd --flag value arg";
  };

  testMkCommandDeeplyNested = {
    expr = libUtil.strings.mkCommand [
      "cmd"
      [
        [ "--a" ]
        [ "--b" ]
      ]
      "end"
    ];
    expected = "cmd --a --b end";
  };

  testMkCommandEmpty = {
    expr = libUtil.strings.mkCommand [ ];
    expected = "";
  };

  testMkCommandSingleElement = {
    expr = libUtil.strings.mkCommand [ "single" ];
    expected = "single";
  };
}

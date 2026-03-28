{ flakeLib, ... }:
{
  testMkCommandSimple = {
    expr = flakeLib.mkCommand [
      "echo"
      "hello"
    ];
    expected = "echo hello";
  };

  testMkCommandNested = {
    expr = flakeLib.mkCommand [
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
    expr = flakeLib.mkCommand [
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
    expr = flakeLib.mkCommand [ ];
    expected = "";
  };

  testMkCommandSingleElement = {
    expr = flakeLib.mkCommand [ "single" ];
    expected = "single";
  };
}

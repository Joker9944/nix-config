{ flakeLib, ... }:
{
  testFirstReturnsFirstElement = {
    expr = flakeLib.first [
      1
      2
      3
    ];
    expected = 1;
  };

  testFirstWithStrings = {
    expr = flakeLib.first [
      "a"
      "b"
      "c"
    ];
    expected = "a";
  };

  testFirstSingleElement = {
    expr = flakeLib.first [ 42 ];
    expected = 42;
  };

  testFirstWithNested = {
    expr = flakeLib.first [
      [
        1
        2
      ]
      [
        3
        4
      ]
    ];
    expected = [
      1
      2
    ];
  };
}

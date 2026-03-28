{ flakeLib, ... }:
{
  testLastReturnsLastElement = {
    expr = flakeLib.last [
      1
      2
      3
    ];
    expected = 3;
  };

  testLastWithStrings = {
    expr = flakeLib.last [
      "a"
      "b"
      "c"
    ];
    expected = "c";
  };

  testLastSingleElement = {
    expr = flakeLib.last [ 42 ];
    expected = 42;
  };

  testLastWithNested = {
    expr = flakeLib.last [
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
      3
      4
    ];
  };
}

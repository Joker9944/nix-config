{ libUtil, ... }:
{
  testLastReturnsLastElement = {
    expr = libUtil.lists.last [
      1
      2
      3
    ];
    expected = 3;
  };

  testLastWithStrings = {
    expr = libUtil.lists.last [
      "a"
      "b"
      "c"
    ];
    expected = "c";
  };

  testLastSingleElement = {
    expr = libUtil.lists.last [ 42 ];
    expected = 42;
  };

  testLastWithNested = {
    expr = libUtil.lists.last [
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

  testLastEmptyListReturnsNull = {
    expr = libUtil.lists.last [ ];
    expected = null;
  };
}

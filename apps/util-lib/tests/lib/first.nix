{ libUtil, ... }:
{
  testFirstReturnsFirstElement = {
    expr = libUtil.lists.first [
      1
      2
      3
    ];
    expected = 1;
  };

  testFirstWithStrings = {
    expr = libUtil.lists.first [
      "a"
      "b"
      "c"
    ];
    expected = "a";
  };

  testFirstSingleElement = {
    expr = libUtil.lists.first [ 42 ];
    expected = 42;
  };

  testFirstWithNested = {
    expr = libUtil.lists.first [
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

  testFirstEmptyListReturnsNull = {
    expr = libUtil.lists.first [ ];
    expected = null;
  };
}

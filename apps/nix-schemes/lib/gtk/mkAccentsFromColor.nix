{ lib, ... }:
color:
lib.pipe
  [
    "blue"
    "teal"
    "green"
    "yellow"
    "orange"
    "red"
    "pink"
    "purple"
    "slate"
  ]
  [
    (lib.map (name: {
      inherit name;
      value = color;
    }))
    lib.listToAttrs
  ]

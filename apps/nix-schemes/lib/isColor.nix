{ lib, ... }:
color:
lib.isAttrs color && lib.hasAttr "dec" color && lib.isList color.dec && lib.length color.dec == 3

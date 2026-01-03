{ lib, ... }: color: lib.isAttrs color && lib.hasAttr "dec" color

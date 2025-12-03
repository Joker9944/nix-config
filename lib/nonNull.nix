{ lib, ... }: value: lib.mkIf (value != null) value

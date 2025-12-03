{ lib, ... }: count: lib.concatStrings (lib.genList (_: " ") count)

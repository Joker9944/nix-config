{ lib, ... }: list: lib.elemAt list ((lib.length list) - 1)

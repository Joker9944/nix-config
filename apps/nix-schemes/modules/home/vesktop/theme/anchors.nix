/**
  The scheme slots each ramp anchor defaults to.

  Only the steps whose role is known from Discord's semantic layer are anchored; the rest of
  every ramp is interpolated in [](./default.nix). The greys follow Discord's own direction
  rather than base24's — `--background-secondary` and `--background-tertiary` are *darker*
  than `--background-primary`, so `base10` and `base11` sit below `base00` on the ramp and
  `base01`/`base02` sit above it.

  # Type

  ```
  anchors :: scheme -> { "primary-600" :: color, … }
  ```
*/
scheme:
let
  inherit (scheme) palette accent status;
in
{
  "primary-130" = palette.base06;
  "primary-230" = palette.base05;
  "primary-330" = palette.base04;
  "primary-400" = palette.base03;
  "primary-500" = palette.base02;
  "primary-560" = palette.base01;
  "primary-600" = palette.base00;
  "primary-700" = palette.base10;
  "primary-800" = palette.base11;

  "brand-500" = accent;
  "red-400" = status.error;
  "green-430" = status.success;
  "yellow-300" = status.warning;
  "orange-300" = palette.base09;
  "blue-345" = status.info;
  "teal-430" = palette.base0C;

  "white-500" = palette.base07;
  "black-500" = palette.base11.darken 0.5;
}

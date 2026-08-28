/**
  Map the palette onto the four UI status colors.

  These follow the conventional UI hues, not the base24 spec's text-editor guidance, which
  assigns `base0F` to warnings — a dark red or brown that is hard to tell from `error`.

  # Type

  ```
  status :: palette -> { info, warning, error, success :: color }
  ```

  # Example

  ```nix
  status scheme.palette
  => { info = <color>; warning = <color>; error = <color>; success = <color>; }
  ```
*/
_: palette: {
  info = palette.base0D;
  warning = palette.base09;
  error = palette.base08;
  success = palette.base0B;
}

/**
  Wrap a list of Hyprland bind arguments into the `{ _args = …; }` attrset
  expected by the hyprland-nix module's Lua serializer.

  # Type

  ```
  mkLuaCall :: [any] -> { _args :: [any] }
  ```

  # Example

  ```nix
  mkLuaCall [ "SUPER + C" (mkLuaInline "hl.dsp.window.close()") { description = "close active window"; } ]
  => { _args = [ "SUPER + C" (mkLuaInline "hl.dsp.window.close()") { description = "close active window"; } ]; }
  ```
*/
_: parts: { _args = parts; }

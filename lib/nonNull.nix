/**
  Conditionally set a value only if it is not null.
  Useful in module configurations to avoid setting options to null.

  # Type

  ```
  nonNull :: a | null -> a
  ```

  # Example

  ```nix
  { config, lib, flakeLib, ... }: {
    home.sessionVariables = {
      EDITOR = flakeLib.nonNull config.programs.editor;
    };
  }
  ```
*/
{ lib, ... }: value: lib.mkIf (value != null) value

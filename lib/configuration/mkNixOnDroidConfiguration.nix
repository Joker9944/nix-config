/**
  Build a nix-on-droid configuration for an Android device.
  Home-manager runs integrated here, composed from the shared home-manager mixin tree.

  # Type

  ```
  mkNixOnDroidConfiguration :: {
    system :: string?,
    hostname :: string,
    additionalModules :: [module]?,
    ...
  } -> nixOnDroidConfiguration
  ```

  # Arguments

  - `system`: System architecture, `aarch64-linux` (default) or `x86_64-linux`
  - `hostname`: Host name, selecting `nixOnDroidModules.hosts-<hostname>`
  - `additionalModules`: Extra modules to include

  # Example

  ```nix
  mkNixOnDroidConfiguration {
    hostname = "my-phone";
  }
  ```
*/
{
  flake,
  lib,
  inputs,
  ...
}:
{
  system ? "aarch64-linux",
  hostname,
  additionalModules ? [ ],
  ...
}:
let
  overlays = [ inputs.nix-on-droid.overlays.default ] ++ lib.attrValues flake.overlays;
in
inputs.nix-on-droid.lib.nixOnDroidConfiguration {
  pkgs = import inputs.nixpkgs { inherit system overlays; };
  home-manager-path = inputs.home-manager.outPath;

  modules = [
    flake.nixOnDroidModules."hosts-${hostname}"
    {
      home-manager = {
        useGlobalPkgs = true;

        # nix-on-droid evaluates home-manager as a bare submodule; restore the two special
        # args standalone home-manager sets. mkClassModule dispatches on `_class`, and
        # `disabledModules` resolves relative paths against `modulesPath`.
        extraSpecialArgs = {
          _class = "homeManager";
          modulesPath = "${inputs.home-manager}/modules";
        };

        sharedModules = [
          flake.homeModules.mixins
          flake.homeModules.theme
          {
            _module.args.pkgs-unstable = import inputs.nixpkgs-unstable { inherit system overlays; };
          }
        ]
        ++ (lib.pipe flake.homeModules [
          (lib.filterAttrs (name: _: lib.hasPrefix "public-" name))
          lib.attrValues
        ]);
      };
    }
  ]
  ++ additionalModules;
}

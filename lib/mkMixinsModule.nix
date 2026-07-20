/**
  Aggregate a directory of mixins, threading a `mkMixinModule` helper (see
  `mkMixinModule.nix`) to each child via `importApply`. Each child declares its
  `enable` flag and gates its config through the helper instead of repeating the
  option + `lib.mkIf` boilerplate.

  `config` is read once here (the aggregator) so children never touch it.

  # Type

  ```
  mkMixinsModule :: { config, dir :: path, prefix :: [string]? } -> module -> module
  ```

  # Arguments

  - `config`: The evaluated module config, used to build the enable conditions
  - `dir`: Directory whose children are imported as mixins
  - `prefix`: Option path segments under `mixins` (e.g. `[ "programs" ]` →
    `mixins.programs.<name>`). Empty for top-level mixins.
  - `module`: Base module merged with the discovered children (for always-on
    config that isn't a mixin)

  # Child usage

  ```nix
  { mkMixinModule, ... }:
  { pkgs, ... }:
  mkMixinModule "atuin" {
    programs.atuin.enable = true;
  }
  ```
*/
{ self, ... }:
{
  config,
  dir,
  prefix ? [ ],
}:
module:
self.mkDefaultModule {
  inherit dir;
  args = {
    mkMixinModule = self.mkMixinModule { inherit config prefix; };
  };
} module

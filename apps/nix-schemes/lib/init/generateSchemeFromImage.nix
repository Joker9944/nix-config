/**
  Generate a color scheme from an image using `base24-gen`.
  The mode (dark/light) is detected automatically from the image unless overridden.
  Returns a scheme object with a chainable `transform` method.

  # Type

  ```
  generateSchemeFromImage :: { image, name?, author?, mode? } -> scheme
  ```

  # Arguments

  - `image`: Path to the source image
  - `name`: Optional scheme name (defaults to the image filename)
  - `author`: Optional author string (defaults to `base24-gen`)
  - `mode`: Optional mode override (`"dark"` or `"light"`); detected automatically when `null`

  # Example

  ```nix
  generateSchemeFromImage { image = ./wallpaper.jpg; }
  => {
    system = "base24";
    name = "wallpaper";
    author = "base24-gen";
    variant = "dark";
    palette = { base00 = <color>; base01 = <color>; ... };
    transform = <function>;
  }
  ```
*/
{
  flake,
  libSchemes,
  lib,
  pkgs,
  ...
}:
{
  image,
  name ? null,
  author ? null,
  mode ? null,
}:
let
  yaml = pkgs.callPackage (
    { runCommand, base24-gen, ... }:
    runCommand "${baseNameOf image}.yaml"
      {
        nativeBuildInputs = [ base24-gen ];
        preferLocalBuild = true;
      }
      (
        let
          cmd =
            lib.pipe
              [
                "base24-gen"
                (lib.optional (mode != null) "--mode ${mode}")
                (lib.optional (name != null) "--name ${name}")
                (lib.optional (author != null) "--author ${author}")
                "--output $out"
                "${image}"
              ]
              [
                lib.flatten
                (lib.concatStringsSep " ")
              ];
        in
        ''
          MODE=$(${cmd} 2>&1 | grep 'Mode:' | sed 's/.*Mode: //')
          echo "mode: $MODE" >> $out
        ''
      )
  ) { inherit (flake.packages.${pkgs.stdenv.hostPlatform.system}) base24-gen; };

  scheme = libSchemes.fromYaml yaml;

  palette = lib.pipe scheme [
    (lib.filterAttrs (name: _: lib.hasPrefix "base" name))
    (lib.mapAttrs (_: hex: libSchemes.fromHex hex))
    (lib.mapAttrs (_: dec: libSchemes.mkColor dec))
  ];

  modifiedScheme = {
    system = "base24";
    name = scheme.scheme;
    inherit (scheme) author;
    variant = scheme.mode;

    inherit palette;
  };

  transform =
    prevScheme: transformFunction:
    let
      currScheme = lib.recursiveUpdate prevScheme (transformFunction prevScheme libSchemes);
    in
    currScheme
    // {
      transform = transform currScheme;
    };
in
transform modifiedScheme (_: _: { })

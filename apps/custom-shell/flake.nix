{
  description = "My Shell flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils/main"; # cSpell:ignore numtide
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ags,
      ...
    }:
    let
      inherit (nixpkgs) lib;
    in
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        astalPackages = with ags.packages.${system}; [
          io
          astal4
        ];

        extraPackages =
          astalPackages
          ++ (with pkgs; [
            libadwaita
            libsoup_3
          ]);

        agsPackage = ags.packages.${system}.default.override {
          inherit extraPackages;
        };
      in
      {
        apps = {
          ags = {
            type = "app";
            program = lib.getExe agsPackage;
          };
        };

        devShells = {
          default = self.devShells.${system}.dev;

          dev = pkgs.mkShell {
            buildInputs = [ agsPackage ];
          };
        };
        packages = {
          default = self.packages.${system}.custom-shell;

          custom-shell = pkgs.stdenv.mkDerivation (finalAttrs: {
            name = "custom-shell";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              wrapGAppsHook3
              gobject-introspection
              ags.packages.${system}.default
            ];

            buildInputs = extraPackages ++ [ pkgs.gjs ];

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin $out/share
              cp -r * $out/share
              ags bundle app.ts $out/bin/${finalAttrs.name} -d "SRC='$out/share'"

              runHook postInstall
            '';
          });
        };
      }
    )
    // {
      overlays = {
        default = self.overlays.custom-shell;

        custom-shell = _: prev: {
          inherit (self.packages.${prev.system}) custom-shell;
        };
      };
    };
}

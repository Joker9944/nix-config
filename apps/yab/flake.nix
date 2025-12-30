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
          network
          wireplumber
          hyprland
        ];

        extraPackages =
          astalPackages
          ++ (with pkgs; [
            libadwaita
            libsoup_3
            libgtop
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
          default = self.packages.${system}.yab;

          yab = pkgs.stdenv.mkDerivation (finalAttrs: {
            name = "yab";

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

            meta =
              let
                inherit (lib) licenses;
              in
              {
                description = "yet another bar";
                license = licenses.free;
                mainProgram = finalAttrs.name;
              };
          });
        };
      }
    )
    // {
      homeManagerModules = {
        default = self.homeManagerModules.yab;
        yab = import ./nix/modules/home self;
      };

      overlays = {
        default = self.overlays.custom-shell;

        yab = _: prev: {
          inherit (self.packages.${prev.system}) yab;
        };
      };
    };
}

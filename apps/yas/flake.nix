{
  description = "yas - yet another shell";

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
          battery
          notifd
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

          yas = {
            type = "app";
            program = lib.getExe self.packages.${system}.yas;
          };
        };

        devShells = {
          default = self.devShells.${system}.dev;

          dev = pkgs.mkShell {
            buildInputs = [
              agsPackage
              ags.packages.${system}.notifd
            ];
          };
        };

        packages = {
          default = self.packages.${system}.yas;

          yas = pkgs.stdenv.mkDerivation (finalAttrs: {
            name = "yas";

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
              ags bundle src/app.tsx $out/bin/${finalAttrs.name} -d "SRC='$out/share'"

              runHook postInstall
            '';

            meta =
              let
                inherit (lib) licenses;
              in
              {
                description = "yet another shell";
                license = licenses.free;
                mainProgram = finalAttrs.name;
              };
          });
        };
      }
    )
    // {
      homeModules = {
        default = self.homeModules.yas;

        yas = lib.modules.importApply ./nix/modules/home { flake = self; };
      };

      overlays = {
        default = self.overlays.yas;

        yas = _: prev: {
          inherit (self.packages.${prev.stdenv.hostPlatform.system}) yas;
        };
      };
    };
}

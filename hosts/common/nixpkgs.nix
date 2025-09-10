{ inputs, ... }:
{
  custom.nixpkgsCompat.additionalNixpkgsInstances = {
    pkgs-unstable = inputs.nixpkgs-unstable;
    pkgs-hyprland = inputs.hyprland.inputs.nixpkgs;
  };
}

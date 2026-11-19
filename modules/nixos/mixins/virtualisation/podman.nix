{ mkMixinModule, ... }:
mkMixinModule "podman" {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  environment.sessionVariables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
}

_: {
  mixins = {
    localization.enable = true;
    nix.enable = true;

    programs = {
      git.enable = true;
      utilities.enable = true;
      vim.enable = true;
    };

    services = {
      maintenance.enable = true;
      tailscale.enable = true;
    };
  };
}

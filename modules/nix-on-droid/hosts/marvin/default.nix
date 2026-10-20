{ flake, ... }@args:
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;
    inherit args;
  }
  {
    environment.etcBackupExtension = ".bak";

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    time.timeZone = "Europe/Zurich";

    # nix-on-droid versions its state separately from nixpkgs; 24.05 is its latest.
    # Read the nix-on-droid changelog before changing this value.
    system.stateVersion = "24.05";
  }

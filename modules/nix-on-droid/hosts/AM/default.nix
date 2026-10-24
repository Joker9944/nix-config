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

    # Pinned so evaluation needs no build: nix-on-droid otherwise reads them from an
    # IFD, which newer Nix cannot build under proot.
    user = {
      uid = 10331;
      gid = 10331;
    };

    # nix-on-droid versions its state separately from nixpkgs; 24.05 is its latest.
    # Read the nix-on-droid changelog before changing this value.
    system.stateVersion = "24.05";
  }

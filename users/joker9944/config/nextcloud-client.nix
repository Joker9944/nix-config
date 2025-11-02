_: {
  programs.nextcloud-client.enable = true;

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}

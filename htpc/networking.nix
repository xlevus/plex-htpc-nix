{
  networking = {
    hostName = "plex-htpc";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
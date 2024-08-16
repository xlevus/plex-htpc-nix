{ modulesPath, pkgs, lib, config, ... }: 

{  
  imports = [
    ./networking.nix
    ./user.nix
  ];  

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

 
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ mcrcon ];

  services.flatpak = {
    enable = true;
    packages = [
        "tv.plex.PlexHTPC"
    ];
  };

  xdg.portal.lxqt.enable = true;
  xdg.portal.config.lxqt.default = [ "lxqt" "gtk" ];

  services.xserver = {
    enable = true;
    windowManager.i3 = {
        enable = true;
    };
  };

  services.displayManager = {
    sddm.enable = true;
    autoLogin.user = username; 
    sddm.autoLogin.relogin = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

}

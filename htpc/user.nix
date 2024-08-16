{ config, pkgs, lib, modulesPath, ... }:
let 
    username = "media-player";
in
{

  users.users."${username}" = {
       isNormalUser = true;
  };

  home-manager.users."${username}" = {
    home.stateVersion = stateVersion;
    home.enableNixpkgsReleaseCheck = false;
    xsession.windowManager.i3 = {
        enable = true;
        config.bars = [];
        config.startup = [
            { command = "flatpak run tv.plex.PlexHTPC"; notification = false; }
        ];
        config.keybindings = {
            "Mod1+n" = "exec nm-connection-editor";
            "Mod1+Shift+q" = "exit";
        };
        config.window.commands = [
            { criteria = { class = "nm-connection-editor"; }; command = "floating enable"; }
            { criteria = { class = "Plex HTPC"; }; command = "fullscreen enable, border none"; }
        ];
    };
  };

}
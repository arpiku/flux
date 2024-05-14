{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    dmenu
    swaylock
    swayidle
    xwayland
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    libinput
  ];

  services.gnome.gnome-keyring.enable = true;


  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.defaultSession = "sway"; #default value for DM
  services.xserver.displayManager.gdm.wayland.enable = true;

  # enable sway window manager
  programs.xwayland.enable = true;

  
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;


    #TODO: Seperate this and configure it further
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };

  programs.waybar.enable = true;

  programs = {
    dconf.enable = true;
    light.enable = true;
  };
 
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
  };
 
}

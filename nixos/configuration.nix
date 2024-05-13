# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  
  networking.hostName = "felix"; #TODO: Allow this value to be passed from flake

  users.users = {
    arpiku = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = []; #ssh keys go here if wish to connect using ssh
      extraGroups = ["networkmanager" "wheel" "audio" "video" ];
    };
  };


  
  #SSH Setup
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };


  ## Custom settings ==============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #For TP-Link Bluetooth enabling
  boot.extraModulePackages = [config.boot.kernelPackages.rtl8821cu];
  
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  #xserver setup 
  services.xserver = {layout = "us"; xkbVariant = "";};

  #Sound Setup
  sound.enable = true;
  hardware.pulseaudio.enable = false;


  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  #Fonts
  fonts.packages = with pkgs; [
    fira-code
    jetbrains-mono
    hack-font
  ];

  #Iphone tethering setup
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    jq
    coreutils-full
  ];

  # Play with it to nuke your system!
  system.stateVersion = "23.11";
}

{ config, pkgs, ... }:

let
  cidkid = import (builtins.fetchGit {
	url = "https://github.com/cidkidnix/nix-overlay.git";
	rev = "1486a0ddf5ee9f26f7b2b2ec58a78c7535a86122";
	ref = "master";
  });

  overrides = import ./overrides.nix;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./filesystem.nix
      ./libvirt.nix
      ./lxd.nix
      ./nix.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "3251f01c";
  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "jupiter-vm"; # Define your hostname.
  networking.networkmanager.enable = true;

  boot.extraModprobeConfig = ''
	options bluetooth disable_ertm=1
	options zfs zfs_arc_max=16426880008
  '';

  security.pam.loginLimits = [ 
     # Pulseaudio
     {
	domain = "cidkid"; 
	item = "priority"; 
	type = "hard"; 
	value = "-20";
     }
     {
	domain = "cidkid"; 
	item = "rtprio"; 
	type = "hard"; 
	value = "99";
     }
  ];

  boot.kernelPatches = [ 
	{
		name = "fsync";
		patch = ./patches/0007-v5.7-fsync.patch;
	}
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Packages
  environment.systemPackages = with pkgs; [
    wget vim git firefox materia-theme papirus-icon-theme
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.pulseaudio = true;
  nixpkgs.overlays = [ (cidkid) (overrides) ];

  fonts.fonts = with pkgs; [
	powerline-fonts
	hack-font
	font-awesome
  ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  programs.sway = {
	enable = true;
	wrapperFeatures.gtk = true;
	extraPackages = with pkgs; [
		swaylock
		swayidle
		xwayland
		alacritty
		wofi
		mako
		grim
		slurp
		kanshi
	];
  };


  hardware.bluetooth.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.daemon.config = {
	high-priority = "yes";
	nice-level = "-15";

	realtime-scheduling = "yes";
	realtime-priority = "50";

	resample-method = "speex-float-0";

	default-fragments = "4";
	default-fragment-size-msec = "6";
  };
  hardware.pulseaudio.configFile = ./cfg/default.pa;
  hardware.opengl.driSupport32Bit = true;

  programs.zsh = {
	enable = true;
	shellAliases = {
		"ls" = "${pkgs.exa}/bin/exa -TL1";
	};
	ohMyZsh = {
		enable = true;
		theme = "agnoster";
	};
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cidkid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "lxd" "libvirtd" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # Don't touch this
  system.stateVersion = "20.09"; # Did you read the comment?

}

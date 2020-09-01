
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
    [ 
      ./hardware-configuration.nix
      ./filesystem.nix
      ./libvirt.nix
      ./nix.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ### ZFS
  networking.hostId = "3251f01c";
  boot.supportedFilesystems = [ "zfs" ];
  
  networking.hostName = "jupiter-desktop";
  networking.networkmanager.enable = true;

  ### Modprobe config
  boot.extraModprobeConfig = ''
	options bluetooth disable_ertm=1
	options zfs zfs_arc_max=16426880008
  '';

/*  
  zramSwap.enable = true;
  zramSwap.algorithm = "lz4";
  boot.kernel.sysctl = {
       "vm.swappiness" = 100;
  };
*/
  

#  virtualisation.anbox.enable = true;
 

  ### limits.conf
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

  ### Kernelpatches
/*  boot.kernelPatches = [ 
	{
		name = "fsync";
		patch = ./patches/0007-v5.7-fsync.patch;
	}
	{
		name = "anbox";
		patch = ./patches/0001-anbox-kernel.patch;
	}


  	{
		name = "anbox-config";
		patch = null;
		extraConfig = ''
			CONFIG_ASHMEM y
			CONFIG_ANDROID y
			CONFIG_ANDROID_BINDER_IPC y
			CONFIG_ANDROID_BINDERFS y
			CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder"
		'';
	}
   ];
*/

#  boot.extraModulePackages = [ config.boot.kernelPackages.anbox ];

  ### Virtual Console
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  ### Timezone
  time.timeZone = "America/Chicago";

  ### Nixpkgs
  environment.systemPackages = with pkgs; [
    wget vim git plata-theme papirus-icon-theme
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.pulseaudio = true;
  nixpkgs.overlays = [ (cidkid) (overrides) ];

  ### Fonts
  fonts.fonts = with pkgs; [
	powerline-fonts
	hack-font
	font-awesome
  ];

  ### Xserver/Wayland
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.desktopManager.gnome3.enable = true;


  ### Sway
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
		playerctl
	];
  };

  
  ### Bluetooth
  hardware.bluetooth.enable = true;
  
  ### Sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;
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

  ### Zsh
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

  ### User account
  users.users.cidkid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    shell = pkgs.zsh;
  };

  ### Don't touch this
  system.stateVersion = "20.09";

}

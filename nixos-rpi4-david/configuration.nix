{ config, pkgs, lib, ... }:

{
# NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
 
  # !!! Otherwise (even if you have a Raspberry Pi 2 or 3), pick this:
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
 
  services.xserver.enable = true; 
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  zramSwap.enable = true;
  zramSwap.algorithm = "lz4";

  environment.systemPackages = with pkgs; [
	multimc
  ];

  ### For framebuffer shit (don't touch)
  boot.kernelParams = ["cma=32M"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
    
  users.users.default = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "cock"; ### Declare user password here
  };
}

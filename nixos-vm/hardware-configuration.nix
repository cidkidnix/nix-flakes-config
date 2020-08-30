{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "nixpool/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "nixpool/store/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "nixpool/nixos/home";
      fsType = "zfs";
    };

  fileSystems."/vmimages" =
    { device = "nixpool/vmimages";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5972-B3BE";
      fsType = "vfat";
    };

  swapDevices = [ ];

}

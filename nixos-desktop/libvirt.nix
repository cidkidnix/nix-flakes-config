{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" "video=HDMI-A-1:1920x1080@75" "video=HDMI-A-2:1920x1080@75" "pcie_aspm=off" ];
  boot.extraModprobeConfig = "options vfio-pci ids=10de:1c82,10de:0fb9";
  boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
  boot.kernelPatches = [
        {
                name = "acso";
		patch = ./patches/0006-add-acs-overrides_iommu.patch;
        }
   ];
  
  virtualisation.libvirtd = {
        enable = true;
        qemuVerbatimConfig = ''
                user = "cidkid"
        '';
  };
}

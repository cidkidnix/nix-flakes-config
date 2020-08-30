{ config, pkgs, ... }:

{
  fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/5fabd7fd-a7fe-4598-9eea-8c9dfb738f62";
        fsType = "xfs";
        options = [ "nofail" ];
  };
}

{ config, pkgs, ... }:

{
  virtualisation.lxd = {
        enable = true;
        recommendedSysctlSettings = true;
  };

  security.apparmor.enable = true;

  users.users.root.subUidRanges = [ { count = 1; startUid = 1000; } ];
  users.users.root.subGidRanges = [ { count = 1; startGid = 1000; } ];
}

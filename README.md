# nix-flakes-config
Nix configs based on flakes


# How to use
- add to your config
``` nix.package = pkgs.nixUnstable;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          ''
 ```
- then clone this repo this repo and issue 
``` nixos-rebuild switch --flake /path/to/clone/dir#system-name defined in flake.nix```

# Warning
- There are missing files that are non-free binaries that you'll have to provide yourself

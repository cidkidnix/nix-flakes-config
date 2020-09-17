# nix-flakes-config
Nix configs based on flakes


# How to use
- add to your config
```nix
          nix.package = pkgs.nixUnstable;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
 ```
- then clone this repo this repo and issue 
``` nixos-rebuild switch --flake /path/to/clone/dir#system-name defined in flake.nix```

# Warning
- There are missing files that are non-free binaries that you'll have to provide yourself

# nixos-virt
- This is a experimental nixOS setup for it to run as a headless system, to basically act as nothing but a hypervisor for everything I use.
- The VM-manager service is a workaround to RX580 reset bug it also makes sure that the main VM stays booted at all times
- The prevent-reset patch should NOT be used if you don't know what you're doing, so please remove it when you don't need it

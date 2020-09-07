{
  inputs = {
	nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland/master";
        home-manager.url = "github:rycee/home-manager/bqv-flakes";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        cidkid.url = "github:cidkidnix/nix-overlay/master";
        cidkid.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-wayland, cidkid }: {

    nixosConfigurations.jupiter-desktop = let 
	cidkid-overlay = import cidkid;
    in nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos-desktop/configuration.nix 
                  home-manager.nixosModules.home-manager
                  ./nixos-desktop/cidkid.nix
      
		  ({ pkgs, config, ... }: {
			config = {
			     nixpkgs.overlays = [ nixpkgs-wayland.overlay cidkid-overlay ];
		  	};
		  })

	         ];
    };

    nixosConfigurations.jupiter-virt = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos-virt/configuration.nix ];
    };

    nixosConfigurations.jupiter-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos-vm/configuration.nix
	          home-manager.nixosModules.home-manager
	          ./nixos-vm/cidkid.nix
      ];
    };

    nixosConfigurations.jupiter-mobile = nixpkgs.lib.nixosSystem {
	system = "aarch64-linux";
	modules = [ ./nixos-mobile/configuration.nix
		    home-manager.nixosModules.home-manager
		    ./nixos-mobile/cidkid.nix
	];
    };

   nixosConfigurations.david-rpi4 = nixpkgs.lib.nixosSystem {
	system = "aarch64-linux";
	modules = [ ./nixos-rpi4-david/configuration.nix ];
   };

};
}

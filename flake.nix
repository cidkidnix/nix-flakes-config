{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:rycee/home-manager/bqv-flakes";

  outputs = { self, nixpkgs, home-manager }: {

    nixosConfigurations.jupiter-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos-desktop/configuration.nix 
                  home-manager.nixosModules.home-manager
                  ./nixos-desktop/cidkid.nix
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

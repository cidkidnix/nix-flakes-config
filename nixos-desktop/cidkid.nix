{ config, pkgs, home-manager, ... }:

{
  home-manager.users.cidkid = {
	programs.git = {
		enable = true;
		userName = "cidkidnix";
		userEmail = "cidkidnix@protonmail.com";
	};
	
	gtk = {
                enable = true;
                theme = {
                        name = "Plata-Noir-Compact";
                        package = pkgs.plata-theme;
                };
		iconTheme = {
			name = "Papirus-Dark";
			package = pkgs.papirus-icon-theme;
		};
        };

        qt = {
                enable = true;
                platformTheme = "gtk";
        };

	home = {
	   sessionVariables = {
		QT_QPA_PLATFORM = "xcb";
		STAGING_AUDIO_DURATION = "60000";
		STAGING_AUDIO_PERIOD = "20000";
		vblank_mode = "0";
	   };

	   packages = with pkgs; [
		firefox discord spotify betterdiscordctl
		steam virt-manager
		psensor nix-prefetch-scripts element-desktop
		unzip pavucontrol multimc vscodium
#		neofetch wine-lutris winetricks protontricks
#		wineserver-kill osu winetricks 
#		tdesktop file minecraft-bedrock killall
		minecraft-bedrock
		sm64pc
	   ];
	};

   };

}

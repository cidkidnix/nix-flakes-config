#let
#  nixpkgs2003_src = builtins.fetchGit {
#        url = "https://github.com/NixOS/nixpkgs";
#        rev = "bb8f0cc2279934cc2274afb6d0941de30b6187ae";
#        ref = "nixos-20.03";
#  };
#
#  nixpkgs2003 = import nixpkgs2003_src {
#        config.allowUnfree = true;
#  };
#in

self: super: rec {

	# This requires the rom to be linked within the build file
	sm64ex = super.stdenv.mkDerivation rec {
		pname = "sm64ex";
		version = "unstable-2020-06-19";
		
		src = builtins.fetchGit {
		  url = "https://github.com/sm64pc/sm64ex.git";
    		  rev = "55a0426cddc40157a2947d6c498aa731e06cc99e";
		  ref = "nightly";
  		};

		nativeBuildInputs = with super; [ python3 pkg-config ];
		buildInputs = with super; [ audiofile SDL2 hexdump git ];

		makeFlags = [ "VERSION=us" "DISCORDRPC=1" "BETTERCAMERA=1" "TEXTURE_FIX=1" "NODRAWINGDISTANCE=1" ];
		preBuild = ''
			patchShebangs extract_assets.py
			cp ${sm64} ./baserom.us.z64
			patch -p1 < enhancements/60fps_ex.patch
		'';

		installPhase = ''
			mkdir -p $out/bin
			cp build/us_pc/sm64.us.f3dex2e $out/bin/sm64ex
		'';
	};

	arc-menu = super.gnomeExtensions.arc-menu.overrideAttrs (_: {
		src = fetchGit {
		url = "https://gitlab.com/arcmenu-team/Arc-Menu.git";
		rev = "e29c66b2318cb35632780f97bd899e57c3856f81";
		};
	});

	### Mesa
/*
	mesa = super.mesa.overrideAttrs (_: {
                src = fetchGit {
                url = "https://gitlab.freedesktop.org/mesa/mesa.git";
                rev = "d19bc94e4eb94a2c8cbdb328c9eaa2faf1ba424c";
                };
        });
*/
	### Wine
	wine-osu = super.wineWowPackages.stable.overrideAttrs (old: {
		patches = (old.patches or []) ++ [ ./patches/wine/pulseaudio.patch ];
	});

	winetricks = super.winetricks.override {
		wine = super.pkgs.wine-osu;
	};

	wine-lutris = super.wineWowPackages.unstable.overrideAttrs (_: {
		src = fetchGit {
			ref = "lutris-5.5";
			url = "https://github.com/lutris/wine.git";
		};
	});

	wineserver-kill = super.writeShellScriptBin "wineserver-kill" ''exec ${super.pkgs.wine-osu}/bin/wineserver -k "$@" '';

	minecraft-bedrock-appimage = super.appimageTools.wrapType2 {
		name = "minecraft-bedrock";
		src = ./cfg/bin/minecraft-bedrock.AppImage;
		extraPkgs = pkgs: with super; [ libpulseaudio alsaLib alsaUtils pkgsi686Linux.zlib ];
	};

	minecraft-bedrock = super.writeTextDir "share/applications/minecraft-bedrock.desktop" ''
		[Desktop Entry]
		Name=Minecraft (Bedrock)
		Type=Application
		Exec=${minecraft-bedrock-appimage}/bin/minecraft-bedrock
		Icon=io.mrarm.mcpelauncher
	'';

	overwatch = super.writeTextDir "share/applications/overwatch.desktop" ''
		[Desktop Entry]
		Name=Overwatch
		Type=Application
		Exec=${overwatch-sh}/bin/overwatch-sh
	'';

	overwatch-sh = super.writeShellScriptBin "overwatch-sh" ''
		export WINEPREFIX="/home/cidkid/.wine-overwatch"
		export vblank_mode=0
		export RADV_PERFTEST=aco
		export vblank_mode=0
		cd /mnt/data/.wine-overwatch/drive_c/Program\ Files\ \(x86\)/Battle.net
		${wine-lutris}/bin/wine Battle.net.exe &
		sleep 2 &
		${wine-lutris}/bin/wine ${wine-ipc-bridge}
	'';

	osu = super.writeTextDir "share/applications/osu.desktop" ''
		[Desktop Entry]
		Name=Osu!
		Type=Application
		Exec=${osu-sh}/bin/osu-sh
	'';

	osu-sh = super.writeShellScriptBin "osu-sh" ''
		export WINEPREFIX="/home/cidkid/.wine-osu"
		export STAGING_AUDIO_DURATION=60000
		export STAGING_AUDIO_PERIOD=20000
		export vblank_mode=0
		cd /home/cidkid/osu
		${wine-osu}/bin/wine osu\!.exe &
		sleep 2 &
		${wine-osu}/bin/wine ${wine-ipc-bridge}
	'';

	sm64pc = super.writeTextDir "share/applications/sm64pc.desktop" ''
		[Desktop Entry]
		Name=SM64pc
		Type=Application
		Exec=${sm64ex}/bin/sm64ex
	'';

	wine-ipc-bridge = super.copyPathToStore ./cfg/bin/wineipc.exe;
	sm64 = super.copyPathToStore ./cfg/bin/sm64.z64;

}


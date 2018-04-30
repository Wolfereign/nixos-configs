{ config, pkgs, ... }: 

{
	# Import other configuration modules
	# (hardware-configuration.nix is autogenerated upon installation)
	# paths in nix expressions are always relative the file which defines them
	imports = [ 
		../../../hardware-configuration.nix
		../../private/hostname.nix
		../../private/users.nix
	];
				
	# Boot Loader
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
		
	# Localization
	time.timeZone = "US/Denver";
	i18n = {
		consoleFont = "roboto-mono";
		consoleKeyMap = "us";
		defaultLocale = "en_US.UTF-8";
	};

	# Networking (Hostname Imported from hostname.nix)
	networking.networkmanager.enable = true;
        
	# i3-gaps / lightdm
	services.xserver.enable = true;
	services.xserver.layout = "us";
	services.xserver.libinput.enable = true; # touchpad support
	services.xserver.displayManager.lightdm.enable = true;
	services.xserver.windowManager = {
		i3 = { enable = true; package = pkgs.i3-gaps; };
		default = "i3";
	};
    
	# Enable Sound
	sound.enable = true;
	hardware.pulseaudio.enable = true;
    
	# Packages
	nixpkgs.config = {
		allowUnfree = true;
		packageOverrides = pkgs: rec {
			polybar = pkgs.polybar.override { i3Support = true; }; 
		};
	};
	
	environment.systemPackages = with pkgs; [
		atom
		audacity
		clipit
		compton
		deluge
		discord
		feh
		firefox
		gimp
		git
		google-chrome
		imagemagick
		libreoffice
		lxappearance
		networkmanagerapplet
		obs-studio
		pango
		polybar
		psmisc
		qutebrowser
		ranger
		rofi
		scrot
		steam-run
		termite
		thunderbird
		tmux
		unzip
		vim
		wget
	];
	
	# Fonts
	fonts = {
		enableFontDir = true;
		enableGhostscriptFonts = true;
		fontconfig.enable = true;
		fonts = with pkgs; [
			roboto
			roboto-mono
		];
	};
						
	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	programs.bash.enableCompletion = true;
	programs.mtr.enable = true;
	programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
 
	# Additional Services/Daemons (also installs?)
	#services.openssh.enable = true;
	services.printing.enable = true; # uses CUPS

	# Firewall
	networking.firewall.enable = true;
	#networking.firewall.allowedTCPPorts = [ 22 ];
	#networking.firewall.allowedUDPPorts = [ ...];
    
	# This value determines the NixOS release with which your system is to be
	# compatible, in order to avoid breaking some software such as database
	# servers. You should change this only after NixOs release notes say you
	# should.
	system.stateVersion = "18.03"; # Did you read the comment?
}

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dead-master";
  networking.extraHosts =
    ''
        127.0.0.2 license.sublimehq.com
    '';
  #networking.wireless.enable = true;

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_MX.UTF-8";

  console = {
     font = "Lat2-Terminus16";
     keyMap = "es";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # GNOME Desktop
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # PANTHEON Desktop
  #services.xserver.desktopManager.pantheon.enable = true;
  #services.xserver.displayManager.lightdm.greeters.pantheon.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  #services.pantheon.apps.enable = true;

  # Xfce Desktop
  #services.xserver.desktopManager.xterm.enable = false;
  #services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.displayManager.defaultSession = "xfce";
  
  # Kde Desktop
  #services.xserver.desktopManager.plasma5.enable = true;

  # I3 Desktop
  environment.pathsToLink = [ "/libexec" ];
  services.xserver = {
	desktopManager = {
      		xterm.enable = false;
    	};
	displayManager = {
        	defaultSession = "none+i3";
	};
	windowManager.i3 = {
		package = pkgs.i3-gaps;
		enable = true;
		extraPackages = with pkgs; [
			picom
			rofi
			sakura
			volumeicon
			polybar
			networkmanager
			networkmanagerapplet
			brightnessctl
			lxappearance
        	dmenu
			xss-lock
        	i3status
        	i3lock
        	i3blocks
			udiskie
			htop
			killall
			leafpad
			neofetch
			unzip
			zip
			pcmanfm
			feh
			unrar
			sxiv
     		];
	};
  };

  # Awesome Desktop
  /*
  services.xserver = {
  
    displayManager = {
      sddm.enable = true;
      defaultSession = "none+awesome";
    };

    windowManager.awesome = {

      enable = true;

      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];

    };

  };
  */

  networking.networkmanager.enable = true;

  programs.dconf.enable = true;

  nix.autoOptimiseStore = true;

  # Configure keymap in X11
  services.xserver.layout = "es";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.printing.drivers = [ pkgs.pkgs.gutenprint ];

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kurumi = {

     isNormalUser = true;
     home = "/home/kurumi";
     description = "Rodrigo Xdn";
     extraGroups = [ "wheel" "networkmanager" ];
     shell = pkgs.zsh;

  };

  # Non-free packages
  nixpkgs.config.allowUnfree = true;

  # Packages of kurumi
  users.users.kurumi.packages = with pkgs; [ 

     go
     python310
     php74
     php74Packages.composer 
     nodejs-17_x
     opera
     freeoffice
     google-chrome
     vlc
     sublime3
     beekeeper-studio
     youtube-dl
     zoom-us
     flameshot
     jp2a

  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

     neovim
     wget
     git
     mariadb
     postgresql
     curl
     zsh

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11";

  # Upgrade of system
  system.autoUpgrade.enable = true;

  system.autoUpgrade.allowReboot = true;

  system.autoUpgrade.channel = https://nixos.org/channels/nixos-21.11;

  # Enable service of mariadb-server
  services.mysql.package = pkgs.mariadb;

  services.mysql.enable = true;

  # Enable service of postgresql
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all ::1/128 trust
      host  all  all 0.0.0.0/0 md5
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE kurumi WITH LOGIN PASSWORD 'pass' SUPERUSER; 
      CREATE DATABASE kurumi;
      GRANT ALL PRIVILEGES ON DATABASE kurumi TO kurumi;
    '';
  };

  # Enable zsh
  programs.zsh.enable = true;
  
}

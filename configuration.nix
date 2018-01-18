# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true; # mount /tmp on tmpfs

  networking.hostName = "trusty-servant"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de_CH-latin1";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  nixpkgs.config.allowUnfree = true;

  # QT4/5 global theme
  environment.etc."xdg/Trolltech.conf" = {
    text = ''
      [Qt]
      style=GTK+
    '';
    mode = "444";
  };

  # GTK3 global theme (widget and icon theme)
  environment.etc."gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-theme-name="Arc-Darker"
      gtk-icon-theme-name="Numix"
    '';
    mode = "444";
  };

  # GTK2 global theme
  environment.etc."gtk-2.0/gtkrc" = {
    text = ''
      gtk-theme-name="Arc-Darker"
      gtk-icon-theme-name="Numix"
    '';
    mode = "444";
  };
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # basic
    wget
    vim
    git
    python3
    firefox
    networkmanagerapplet
    gnupg
    borgbackup
    cifs-utils
    psmisc # tree, killall, etc
    nix-zsh-completions
    busybox # common tools

    # yubikey stuff
    pcsctools
    yubikey-personalization
    
    # appearance
    lxappearance 
    arc-theme
    numix-icon-theme
    notify-osd # notification server
  ];

  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      roboto
      gentium-book-basic
      font-awesome-ttf
      siji
      powerline-fonts
      hack-font
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.zsh.enableCompletion = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.zsh.enable = true;

  # List services that you want to enable:

  # for smartcards (yubikey)
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
  
  # battery management
  services.tlp.enable = true;

  services.gnome3.gnome-keyring.enable = true;

  # backlight control
  programs.light.enable = true;

  # java
  programs.java.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "ch";
  services.xserver.xkbOptions = "eurosign:e";

  # auto locking
  services.xserver.xautolock = {
    enable = true;
    enableNotifier = true;
    notify = 20;
    time = 15; # minutes
    locker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy";
  };
 
  # lock on suspend
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xss-lock}/bin/xss-lock -- ${pkgs.i3lock-fancy}/bin/i3lock-fancy &
  '';

  # redshift
  services.redshift = {
    enable = true;
    provider = "geoclue2";
  };

  # compton for wm rendering
  services.compton.enable = true;

  hardware.pulseaudio.enable = true;

  virtualisation.docker.enable = true;

  # Enable touchpad support.
  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    accelProfile = "flat"; # disable accel
    tapping = false; # disable tap click
  };

  services.xserver.displayManager.lightdm = {
    enable = true;
    background = "${pkgs.nixos-artwork.wallpapers.stripes-logo}/share/artwork/gnome/nix-wallpaper-stripes-logo.png";
    greeters.gtk = {
      enable = true;
      theme = { name = "Arc-Darker"; package = pkgs.arc-theme; };
    };
  };

  services.accounts-daemon.enable = true;

  # Enable the i3 Desktop Environment.
  services.xserver.windowManager.i3= {
    enable = true;
    package = pkgs.i3-gaps;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.extraUsers.robin = {
    isNormalUser = true;
    home = "/home/robin";
    useDefaultShell = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  fileSystems."/home/robin/Downloads" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "size=25%" ]; };

  # allow tlp-stat without password
  security.sudo.extraConfig = ''
      robin ALL=(root) NOPASSWD: /run/current-system/sw/bin/tlp-stat
    '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}

{ config, pkgs, ... }:

{
  imports =
    [ # Bindet die automatisch generierte Hardware-Config ein
      ./hardware-configuration.nix
    ];

  # --- Bootloader & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # STRATEGIE: Wir nutzen für die Installation erst 'linuxPackages_latest'.
  # Sobald das System läuft und wir auf Flakes umgestellt haben, 
  # tauschen wir dies gegen den CachyOS-Kernel (via chaotic-nyx) aus.
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  # ZFS Unterstützung aktivieren
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "8425e349"; 

  # --- Verschlüsselung (LUKS) ---
  boot.initrd.luks.devices = {
    "crypt_root1" = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
    "crypt_root2" = {
      device = "/dev/nvme1n1p2";
      preLVM = true;
    };
  };

  # --- Networking ---
  networking.hostName = "kohaku";
  networking.networkmanager.enable = true;
  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PermitEmptyPasswords = "no";
    };
  };
  # --- Keyboard/Language ---
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  # --- Optimierungen ---
  zramSwap.enable = true;
  
  # --- Grafik (Nvidia RTX 5060) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    
    # Auf 'true' gesetzt für Open Kernel Modules.
    # Empfohlen für RTX Karten und modernere Kernel (wie CachyOS später).
    open = true; 
    
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # --- User & System ---
  users.users.haku = { 
    isNormalUser = true;
    # Hier kannst du schreiben, was du willst (Anzeigename)
    description = "Haku"; 
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  # --- Flakes & Nix Command aktivieren ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    pciutils
    htop
  ];

  system.stateVersion = "24.11"; 
}

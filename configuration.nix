{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Hardware Config
      ./hardware-configuration.nix

      ./modules/zfs-snapshots.nix
      # Chaotic-Nyx Module (kommt aus flake.nix)
      # inputs.chaotic.nixosModules.default (Wird über flake.nix geladen)
      
      # Sops-Nix Modul für Secrets Management
      inputs.sops-nix.nixosModules.sops
    ];

  # --- Bootloader & Kernel (CachyOS High Performance) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # --- Remote Unlock (Initrd SSH) ---
  boot.initrd = {
    # WICHTIG: Hier muss der Treiber deiner Netzwerkkarte stehen!
    kernelModules = [ "r8169" ];

    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        # Der Public Key deines Laptops (dieselbe Zeile wie bei users.users.haku)
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMD0q9gEM7isC6P98pLnNcEaoGP88toK3z+AqU9Gsx4 rootlogic7@proton.me" ];
        # Damit du keine "Host Key changed" Warnung bekommst, nutzen wir den Host-Key
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
      postCommands = ''
        ip addr add 192.168.178.20/24 dev enp4s0
        ip link set enp4s0 up
      ''; 
    };
  };

  # Der optimierte CachyOS Kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # Zusätzliche Kernel-Parameter für Nvidia & Performance
  boot.kernelParams = [
    "nvidia-drm.fbdev=1" 
    "quiet" "splash"
  ];

  # NEU: ZRAM (Komprimierter RAM-Swap für bessere Performance)
  zramSwap.enable = true;

  # CachyOS Scheduler (scx) - "lavd" ist 2026 der Goldstandard für Gaming
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  
  # Ananicy-Cpp: Automatische Prozess-Priorisierung
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # ZFS Settings
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "8425e349"; 
  
  # LUKS Verschlüsselung (Root + HDDs)
  boot.initrd.luks.devices = {
    # System (NVMe)
    "crypt_root1" = { device = "/dev/nvme0n1p2"; preLVM = true; };
    "crypt_root2" = { device = "/dev/nvme1n1p2"; preLVM = true; };
    
    # Storage (HDDs) - IDs basierend auf deiner Hardware
    "crypt_safe1" = { device = "/dev/disk/by-id/ata-TOSHIBA_DT01ACA200_94JKP2VHS-part1"; preLVM = true; };
    "crypt_safe2" = { device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K5LD8Y9V-part1"; preLVM = true; };
    "crypt_extra" = { device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K5LD8Y9V-part2"; preLVM = true; };
  };

  # --- Storage (HDDs) ---
  # Hier binden wir die neuen Pools ein.
  # 1. Der sichere Mirror (Backups)
  fileSystems."/storage/backup" = {
    device = "safe/backup";
    fsType = "zfs";
  };

  # 2. Der Massenspeicher (Medien)
  fileSystems."/storage/media" = {
    device = "extra/media";
    fsType = "zfs";
  };
  
  # --- Secrets Management (Sops) ---
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # Nutzt den Host-SSH-Key, um Secrets beim Booten zu entschlüsseln
    # Das bedeutet: Nur dieser PC kann die Secrets lesen!
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    
    # TEST: Wir aktivieren das 'test_secret' um zu prüfen, ob alles klappt.
    # (Voraussetzung: Du hast 'test_secret' in der secrets.yaml angelegt)
    secrets.test_secret = {};
  };

  # --- Networking ---
  networking.hostName = "kohaku";
  networking.networkmanager.enable = true;
  # NEU: Explizite DNS Server (Cloudflare & Google oder dein Router-IP)
  networking.nameservers = [ "1.1.1.1" ];

  # WICHTIG: Damit nach dem Booten das Gateway automatisch gefunden wird
  networking.interfaces.enp4s0.useDHCP = true;
  
  # Firewall Konfiguration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
  
  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PermitEmptyPasswords = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # --- Locale & Time ---
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # --- Hyprland & Grafik ---
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Gamemode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
    };
  };

  # Login Manager (SDDM)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Environment Variablen
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; 
    WLR_NO_HARDWARE_CURSORS = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  # Grafiktreiber
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  services.xserver.videoDrivers = ["nvidia"];
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false; 
    open = true; 
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # --- Shell & Tools ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    pciutils
    htop
    fastfetch
    kitty
    ghostty
    wl-clipboard
    yazi
    mangohud 
    
    # Sops Tool für CLI
    sops
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # --- User ---
  users.users.haku = { 
    isNormalUser = true;
    description = "Haku"; 
    extraGroups = [ "networkmanager" "wheel" "video" "gamemode" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMD0q9gEM7isC6P98pLnNcEaoGP88toK3z+AqU9Gsx4 rootlogic7@proton.me"
    ];
  };

  # Binary Cache Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://chaotic-nyx.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "chaotic-nyx.cachix.org-1:dHw3kV0d+x7O25psfwbP6tV76r4ivI8pshwlSwP63cs="
    ];
  };
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "24.11"; 
}

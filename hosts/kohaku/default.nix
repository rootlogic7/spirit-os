{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/users/haku.nix
    ../../modules/hardware/zfs-snapshots.nix
  ];

  networking.hostName = "kohaku";
  networking.hostId = "8425e349"; 

  # --- Bootloader & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernelParams = [ "quiet" "splash" "console=tty1" "video=DP-1:3440x1440@100" "video=HDMI-A-1:1920x1080@100" ];

  # --- Initrd Network & SSH Unlock ---
  boot.initrd = {
    kernelModules = [ "r8169" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6FGcKzp9lwFTWQXNNLB1xJC07rTWJeK2GN0J9mcjqg rootlogic7@proton.me" ];
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
      postCommands = ''
        ip addr add 192.168.178.20/24 dev enp4s0
        ip link set enp4s0 up
      '';
    };
  };

  # --- Performance ---
  zramSwap.enable = true;
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # --- Storage (ZFS & LUKS) ---
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.trim.enable = true;

  fileSystems."/storage/backup" = { device = "safe/backup"; fsType = "zfs"; };
  fileSystems."/storage/media"  = { device = "extra/media"; fsType = "zfs"; };

  fileSystems."/persist".neededForBoot = true;

  boot.initrd.luks.devices = {
    "crypt_safe1" = { device = "/dev/disk/by-id/ata-TOSHIBA_DT01ACA200_94JKP2VHS-part1"; preLVM = true; };
    "crypt_safe2" = { device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K5LD8Y9V-part1"; preLVM = true; };
    "crypt_extra" = { device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K5LD8Y9V-part2"; preLVM = true; };
  };
  
  # === ERASE YOUR DARLINGS (EYD) MAGIE ===

  # 1. ZFS Rollback bei jedem Boot (Setzt Root auf den leeren Snapshot zurück)
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/root@blank
  '';

  # 2. Impermanence Konfiguration (Das hier bleibt über Neustarts hinweg erhalten)
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections" # Behält deine WLAN/LAN Passwörter
    ];
    files = [
      "/etc/machine-id"
      # Deine SOPS-Keys (WICHTIG!)
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  # =======================================

  # --- Networking ---
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  networking.interfaces.enp4s0.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --- Secrets ---
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets."haku-password".neededForUsers = true;
  };

  # Hyprland aktivieren
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  programs.gamemode.enable = true;
  # programs.gamescope.enable = true;

  # Steam Installation und Optimierung
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Öffnet Ports für Steam Remote Play
    dedicatedServer.openFirewall = true; # Öffnet Ports für Source-Server
    localNetworkGameTransfers.openFirewall = true; # Erlaubt Transfers im LAN
  };
  # --- Home-Manager Host-Overrides für Kohaku ---
  home-manager.users.haku = { lib, pkgs, ... }: {
    
    # Desktop-spezifische Pakete hinzufügen
    home.packages = with pkgs; [
      vesktop
      mangohud
    ];

    # Hardware-spezifische Hyprland Settings
    wayland.windowManager.hyprland.settings = {
      # mkForce überschreibt die Fallback-Liste aus der home.nix komplett
      monitor = lib.mkForce [
        "DP-1,3440x1440@100,0x0,auto"
        "HDMI-A-1,1920x1080@100,3440x0,auto"
      ];
      
      workspace = lib.mkForce [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-1"
        "5, monitor:DP-1"
        "6, monitor:HDMI-A-1, default:true"
        "7, monitor:HDMI-A-1"
        "8, monitor:HDMI-A-1"
        "9, monitor:HDMI-A-1"
        "10, monitor:HDMI-A-1"
      ];

      input = {
          accel_profile = lib.mkForce "flat";
      };
    };
  };

  # 1. Wir aktivieren sysc-greet, damit das System das Paket und die Configs baut
  services.sysc-greet = {
    enable = true;
    compositor = "hyprland"; 
  };

  # 2. HIJACK: Wir überschreiben den TTY-Startbefehl von sysc-greet mit Gewalt!
  # Statt im fehlerhaften TTY zu starten, zünden wir unsere minimale Hyprland-Sitzung.
  services.greetd.settings.default_session = pkgs.lib.mkForce {
    command = "start-hyprland";
    user = "greeter";
  };

  # 3. Die Konfiguration für das "Greeter-Hyprland" (Nur für Kohaku!)
  environment.etc."greetd/hyprland.conf".text = ''
    # --- Nvidia Environment Variables ---
    env = LIBVA_DRIVER_NAME,nvidia
    env = XDG_SESSION_TYPE,wayland
    env = GBM_BACKEND,nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    env = NIXOS_OZONE_WL,1
    
    # --- Monitore ---
    monitor=DP-1,3440x1440@100,0x0,1
    monitor=HDMI-A-1,1920x1080@100,3440x0,1

    workspace = 1, monitor:DP-1, default:true

    misc {
      disable_splash_rendering = true
      disable_hyprland_logo = true
      background_color = 0x000000
    }
    animations {
      enabled = false
    }
    
    # --- Autostart: Kitty öffnet sich und startet sysc-greet! ---
    exec-once = [workspace 1 silent; fullscreen] ${pkgs.kitty}/bin/kitty -e sysc-greet
  '';

  # 4. DEIN TRICK: Wir verlinken die Config ins Home-Verzeichnis des Greeter-Users!
  # systemd führt das aus, kurz bevor der Greeter startet.
  systemd.services.greetd.preStart = ''
    mkdir -p /var/lib/greeter/.config/hypr
    ln -sf /etc/greetd/hyprland.conf /var/lib/greeter/.config/hypr/hyprland.conf
    chown -R greeter:greeter /var/lib/greeter
  '';

  system.stateVersion = "24.11"; 
}

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/zfs-snapshots.nix
    ../../modules/users/haku.nix
  ];

  networking.hostName = "kohaku";
  networking.hostId = "8425e349"; 

  # --- Bootloader & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [
    "quiet"
    "splash"
    "console=tty1"
    "video=DP-1:3440x1440@100"
    "video=HDMI-A-1:1920x1080@60"
  ];

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
  
  # --- QEMU-Emulation for building yashiro ---
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # --- Storage (ZFS & LUKS) ---
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.trim.enable = true;

  fileSystems."/storage/backup" = { device = "safe/backup"; fsType = "zfs"; };
  fileSystems."/storage/media"  = { device = "extra/media"; fsType = "zfs"; };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;

  boot.initrd.luks.devices = {
    "crypt_safe1" = { device = "/dev/disk/by-id/ata-TOSHIBA_DT01ACA200_94JKP2VHS-part1"; preLVM = true; };
    "crypt_safe2" = { device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K5LD8Y9V-part1"; preLVM = true; };
    "crypt_extra" = { device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K5LD8Y9V-part2"; preLVM = true; };
  };
  
  # === ERASE YOUR DARLINGS (EYD) MAGIE ===

  # 1. ZFS Rollback bei jedem Boot (Setzt Root auf den leeren Snapshot zurück)
  #boot.initrd.postDeviceCommands = lib.mkAfter ''
  #  # 1. Warte, bis alle Geräte (nach der LUKS-Passworteingabe) vollständig geladen sind
  #  udevadm settle

  # # 2. Zwinge das System, den Pool jetzt zu importieren (falls es das nicht schon getan hat)
  #  zpool import -N rpool || true

     # 3. Jetzt, wo der Pool garantiert da ist: ZFS Rollback!
  #  zfs rollback -r rpool/root@blank
  #  zfs rollback -r rpool/home@blank
  # '';
  # =======================================
  
  # Aktiviere das moderne Systemd in der Initrd (Stage 1)
  boot.initrd.systemd.enable = true;

  # Erstelle einen dedizierten, absturzsicheren Rollback-Dienst
  boot.initrd.systemd.services.zfs-rollback = {
    description = "Rollback ZFS datasets to a pristine state (Erase Your Darlings)";
    wantedBy = [ "initrd.target" ];
    # Zwingt den Dienst zu warten, bis LUKS offen und der ZFS-Pool importiert ist
    after = [ "zfs-import-rpool.service" ];
    # Zwingt den Dienst, fertig zu sein, BEVOR das System das Root-Laufwerk mountet
    before = [ "sysroot.mount" ];
    path = with pkgs; [ zfs ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool/root@blank
      zfs rollback -r rpool/home@blank
    '';
  };

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
        "HDMI-A-1,1920x1080@60,3440x0,auto"
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
  
  # --- Host-spezifische Greeter Konfiguration (Kohaku) ---
  environment.etc."greetd/hyprland.conf".text = lib.mkBefore ''
    # --- Nvidia Environment Variables ---
    env = LIBVA_DRIVER_NAME,nvidia
    env = XDG_SESSION_TYPE,wayland
    env = GBM_BACKEND,nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    env = NIXOS_OZONE_WL,1
    
    # --- Monitore: Physische Aufstellung ---
    monitor=DP-1,3440x1440@100,0x0,1
    monitor=HDMI-A-1,1920x1080@60,3440x0,1
    
    workspace = 1, monitor:DP-1, default:true
    
    # --- Cursor in die Ecke von DP-1 teleportieren ---
    exec-once = ${pkgs.hyprland}/bin/hyprctl dispatch movecursor 3439 1439
  '';

  system.stateVersion = "25.11"; 
}

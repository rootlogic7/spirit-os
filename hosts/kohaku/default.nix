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
  boot.kernelParams = [ "quiet" "splash" ];

  # --- Initrd Network & SSH Unlock ---
  boot.initrd = {
    kernelModules = [ "r8169" ];
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

  # --- Display Manager (SDDM) ---
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    # Theme Paket
    (catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font  = "JetBrainsMono Nerd Font";
      loginBackground = true;
    })
    # QT Dependencies für Themes
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtsvg
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    theme = "catppuccin-mocha-mauve";
  };

  # --- X11 Setup Script (FIXED) ---
  # Wird ausgeführt, bevor SDDM startet.
  services.xserver.displayManager.setupCommands = ''
    # HDMI Monitore ausschalten
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --off
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-A-1 --off

    # Hauptmonitor (DP-0) konfigurieren
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --mode 3440x1440 --rate 100 --primary
  '';
  # Hyprland aktivieren
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  programs.gamemode.enable = true;

  # Steam Installation und Optimierung
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Öffnet Ports für Steam Remote Play
    dedicatedServer.openFirewall = true; # Öffnet Ports für Source-Server
    localNetworkGameTransfers.openFirewall = true; # Erlaubt Transfers im LAN
  };

  system.stateVersion = "24.11"; 
}

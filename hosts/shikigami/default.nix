{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/users/haku.nix
  ];

  networking.hostName = "shikigami";
  networking.hostId = "1a2b3c4d"; 

  # --- Bootloader & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Standard-Kernel statt chaotic-nyx (besser für Laptops und 8GB RAM)
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [ 
    "quiet" 
    # WICHTIG: Limitiert den ZFS Cache auf max 1.5 GB (1536 * 1024 * 1024)
    "zfs.zfs_arc_max=1610612736" 
  ];

  # --- Storage & LUKS ---
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.trim.enable = true;

  # Für die Initrd: NVMe- und Krypto-Module laden
  boot.initrd.availableKernelModules = [ "nvme" "aesni_intel" "cryptd" ];

  # === ERASE YOUR DARLINGS (EYD) MAGIE ===
  # ZFS Rollback bei jedem Boot
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/root@blank
  '';

  # Persistenz (nur das absolut Nötigste für den Boot)
  fileSystems."/persist".neededForBoot = true;
  
  # --- IMPERMANENCE (Wichtig für den Laptop!) ---
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections" # Behält WLAN Passwörter
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  # --- SECRETS (SOPS) ---
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets."haku-password".neededForUsers = true;
  };

  # Basis-Netzwerk
  networking.networkmanager.enable = true;
  system.stateVersion = "24.11"; 
}

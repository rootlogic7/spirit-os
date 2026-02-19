{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "shikigami";
  # ZFS benötigt zwingend eine Host-ID. Generiere am besten eine eigene mit `head -c 8 /etc/machine-id`
  # oder nimm hier temporär eine zufällige:
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
  
  # Basis-Netzwerk
  networking.networkmanager.enable = true;

  # Root-Passwort temporär setzen (da wir noch keine User/SOPS haben)
  # WICHTIG: Ändere das Passwort nach dem ersten Login!
  users.users.root.initialPassword = "root";

  system.stateVersion = "24.11"; 
}

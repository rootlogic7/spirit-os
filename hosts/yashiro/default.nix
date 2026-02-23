{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    ../../modules/core/sops.nix # Dein bestehendes SOPS-Modul
  ];

  # Pi-spezifische Hardware-Module (aus deiner cat-Ausgabe + Netzwerk)
  boot.initrd.availableKernelModules = [ 
    "xhci_pci"     # USB/SD-Controller
    "pcie_brcmstb" # Pi 4 PCIe
    "bcm_genet"    # Pi 4 Netzwerk-Chip (ESSENTIELL für SSH-Unlock!)
  ];

  # Remote Unlock Setup
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222; # Separter Port zum Entsperren
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHa4bO683OVwOVR9sc2aGDT/OI0A1TAkaPUQ6rhnwmqQ haku@shikigami" ];
      hostKeys = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
  };

  # Bootloader Einstellungen für den Pi
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Impermanence & Persistenz
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/nixos"
      "/var/log"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # SSH & User Setup wie auf Kohaku/Shikigami
  services.openssh.enable = true;
  
  # Architektur festlegen
  nixpkgs.hostPlatform = "aarch64-linux";
  
  networking.hostName = "yashiro";
}

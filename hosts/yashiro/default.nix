{ config, pkgs, lib, ... }:

{
  # Hardware-Module
  boot.initrd.availableKernelModules = [ "xhci_pci" ];

  # Remote Unlock Setup (ohne hostKeys!)
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHa4bO683OVwOVR9sc2aGDT/OI0A1TAkaPUQ6rhnwmqQ haku@shikigami" ];
      hostKeys = [ ./initrd-ssh-key ];
    };
  };

  # Bootloader Einstellungen für den Pi
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Dateisystem-Fix für Impermanence
  fileSystems."/persist".neededForBoot = true;

  # SSH
  services.openssh.enable = true;

  # Architektur & System
  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "yashiro";
  system.stateVersion = "25.11";

  hardware.enableRedistributableFirmware = true;
  hardware.deviceTree = {
    enable = true;
    filter = "*rpi-4-*.dtb";
  };

  # User Konfiguration
  users.users.haku = {
    isNormalUser = true;
    description = "Haku";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHa4bO683OVwOVR9sc2aGDT/OI0A1TAkaPUQ6rhnwmqQ haku@shikigami" ];
  };
}

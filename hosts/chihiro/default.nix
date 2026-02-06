{ config, pkgs, vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/users/${vars.user}.nix
    ../../modules/hardware/zfs-snapshots.nix 
  ];

  networking.hostName = "chihiro";
  networking.hostId = "cafebabe"; # Wichtig für ZFS (darf nicht gleich wie kohaku sein)

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  
  # Kernel-Parameter für Intel GPU Energiesparen
  boot.kernelParams = [ "i915.enable_guc=2" ];

  # Hardware: Firmware & Intel
  hardware.enableRedistributableFirmware = true; # Für Intel WiFi
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Hardware Video Acceleration
      vaapiIntel 
    ];
  };

  # Netzwerk
  networking.networkmanager.enable = true;

  # Power Management (Wichtig für Laptops)
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Secrets (ACHTUNG: Temporär deaktivieren für Installation, s.u.)
  # sops = { ... }; 
  # Workaround für ersten Login:
  users.users.${vars.user}.initialPassword = "password"; 

  # Display Manager & Desktop
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve";
  };
  programs.hyprland.enable = true;

  system.stateVersion = "24.11"; 
}

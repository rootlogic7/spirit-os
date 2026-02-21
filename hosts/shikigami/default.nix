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
  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
  
  # --- Grafik & Desktop
  hardware.graphics.enable = true;
  programs.hyprland.enable = true;  
  # --- Home-Manager Host-Overrides für Shikigami ---
  home-manager.users.haku = { lib, pkgs, ... }: {
    
    home.packages = with pkgs; [
      brightnessctl
    ];

    wayland.windowManager.hyprland.settings = {
      # Interner Laptop-Monitor
      monitor = lib.mkForce [
        "eDP-1,preferred,auto,1"
      ];
      
      # Zwingt Workspaces 1-5 auf den Laptop-Bildschirm
      workspace = lib.mkForce [
        "1, monitor:eDP-1, default:true"
        "2, monitor:eDP-1"
        "3, monitor:eDP-1"
        "4, monitor:eDP-1"
        "5, monitor:eDP-1"
      ];

      # Touchpad-Gesten
      input = {
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };
      # --- Media & Helligkeits-Tasten ---
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];
    };
  };
  
  # --- Audio (PipeWire) ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Display Manager (Greetd + Tuigreet) ---
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-user-session --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  system.stateVersion = "24.11"; 
}

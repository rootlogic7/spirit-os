{ config, pkgs, lib, ... }:{
  # === === === === === === === === === 
  # === --- --- Imports --- --- --- ===
  # === === === === === === === === === 
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/users/haku.nix
  ];
  # === === === === === === === === === 
  # === --- --- Networking  --- --- ===
  # === === === === === === === === === 
  networking = {
    hostName = "shikigami";
    hostId = "da52ad94"; 
    networkmanager = {
      enable = true;
    };
  };

  # === === === === === === === === === 
  # === --- --- --- Boot -- --- --- ===
  # === === === === === === === === === 
  boot = {

    # === Bootloader ===
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      timeout = 3;
      efi = {
        canTouchEfiVariables = true;
      };
    };

    # === Plymouth ===
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };
    consoleLogLevel = 3;

    # === Initrd ===
    initrd = {
      verbose = false;
      availableKernelModules = [
        "nvme" 
        "aesni_intel" 
        "cryptd" 
      ];
      
      # === systemd ===
      systemd = {
        enable = true;
        services = {
          zfs-rollback = {
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
        };
      };
    };
    # === Kernel ===
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [ 
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
      # WICHTIG: Limitiert den ZFS Cache auf max 1.5 GB (1536 * 1024 * 1024)
      "zfs.zfs_arc_max=1610612736"
    ];

    # === Filesystems ===
    supportedFilesystems = [ "zfs" ];
  };


  # === === === === === === === === === 
  # === --- --- - Services  --- --- ===
  # === === === === === === === === === 
  services = {

    # === zfs ===
    zfs = {
      trim = {
        enable = true;
      };
    };

    # === pipewire ===
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse = {
        enable = true;
      };
    };
  };

  # === === === === === === === === === 
  # === --- --- FileSystems --- --- ===
  # === === === === === === === === === 
  fileSystems = {
    "/persist".neededForBoot = true;
    "/home".neededForBoot = true;
  };
  
  # === === === === === === === === === 
  # === --- --- --- sops -- --- --- ===
  # === === === === === === === === === 
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets."haku-password".neededForUsers = true;
  };

  # === === === === === === === === === 
  # === --- --- Environment --- --- ===
  # === === === === === === === === === 
  environment = {
    pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
    etc = { 
      "greetd/hyprland.conf" = {
        text = lib.mkBefore ''
          # --- Monitor für Laptop ---
          monitor=eDP-1,1366x768,0x0,1
          monitor=DP-5,1280x1024,0x-1024,1
    
          # --- Cursor in die Ecke teleportieren ---
          exec-once = ${pkgs.hyprland}/bin/hyprctl dispatch movecursor 1365 767
        '';
      };
    };
  };

  # === === === === === === === === === 
  # === --- --- Desktop --- --- --- ===
  # === === === === === === === === === 
  hardware.graphics.enable = true;
  programs.hyprland.enable = true;

  # === === === === === === === === === 
  # === --- --- Home Manager -- --- ===
  # === === === === === === === === === 
  home-manager.users.haku = { lib, pkgs, ... }: {
    
    home.packages = with pkgs; [
      brightnessctl
    ];

    wayland.windowManager.hyprland.settings = {
      # Interner Laptop-Monitor
      monitor = lib.mkForce [
        "eDP-1,1366x768@60.06,0x0,1"
        "DP-5,1280x1024@60.02,43x-1024,1"
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
  
  
  system.stateVersion = "25.11"; 
}

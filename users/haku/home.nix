{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/spirit-nix/default.nix
  ];

  home.username = "haku";
  home.homeDirectory = "/home/haku";
  
  # --- Generische Pakete (für alle Rechner) ---
  home.packages = with pkgs; [
    firefox
    yazi
    obsidian
    keepassxc
  ];

  # === DIESEN BLOCK HINZUFÜGEN ===
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        host = "github.com";
        user = "git";
        identityFile = "/run/secrets/github-ssh-key";
        identitiesOnly = true;
      };
    };
  };
  # ===============================

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Haku";
        email = "rootlogic7@proton.me";
      };
      init.defaultBranch = "main";
    };
  };

  # --- Hardware-Agnostische Hyprland Fallbacks ---
  wayland.windowManager.hyprland.settings = {
    # Ein generischer Fallback-Monitor, falls der Host nichts definiert
    monitor = lib.mkDefault [ ",preferred,auto,1" ];

    input = {
      # Standardmäßig keine Mausempfindlichkeits-Änderung
      sensitivity = lib.mkDefault 0;
    };
  };

  home.stateVersion = "24.11";
}

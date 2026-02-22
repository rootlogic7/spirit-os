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

  programs.firefox = {
    enable = true;
    profiles.haku = {
      isDefault = true;
      id = 0;
      # Dies sorgt dafür, dass Firefox immer exakt dieses Profil nutzt
      # und die Add-ons sowie Einstellungen darin behält.
    };
  };

  home.stateVersion = "24.11";
}

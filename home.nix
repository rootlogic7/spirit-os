{ config, pkgs, ... }:

{
  # Home Manager braucht diese Infos
  home.username = "haku";
  home.homeDirectory = "/home/haku";
  
  # User-spezifische Pakete
  home.packages = with pkgs; [
    # --- GUI & Tools ---
    ghostty         # Dein Haupt-Terminal
    # kitty         # BACKUP: Falls Ghostty mal crasht (kannst du auskommentiert lassen)
    yazi            # File Manager
    wl-clipboard    # Clipboard für Wayland (wichtig für Neovim/Yazi)
    
    # --- Gaming ---
    mangohud        # Overlay
    # protonup-qt   # Optional: Um Proton-GE einfach zu installieren
    
    # --- CLI Power-Tools (passen zum "Power-User" Thema) ---
    ripgrep         # "rg": Extrem schnelles Grep (nutzt Neovim oft intern)
    fd              # "fd": Schnelleres 'find'
    btop            # Viel schickerer/detaillierterer Task-Manager als htop
    tldr            # Einfachere Man-Pages (z.B. "tldr tar")
    fzf             # Fuzzy Finder (für History-Suche etc.)
  ];

  # --- Hyprland Konfiguration ---
  wayland.windowManager.hyprland = {
    enable = true;
    
    # Hier passiert die Magie: Wir schreiben die Config direkt in Nix
    settings = {
      # Monitor Setup (Auto)
      monitor = [ "DP-1,3440x1440@100,0x0,auto" "HDMI-A-1,1920x1080@100,3440x0,auto" ];

      cursor = {
        no_hardware_cursors = true;
      };

      # Eingabegeräte
      input = {
        kb_layout = "de";
        kb_variant = "";
        follow_mouse = 1;
        touchpad.natural_scroll = "no";
      };

      # Variablen
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$fileManager" = "ghostty -e yazi";

      # Tastenbindungen
      bind = [
        # Wichtig: Startet Ghostty statt Kitty!
        "$mod, Q, exec, $terminal"
        
        # Fenster schließen / Hyprland beenden
        "$mod, C, killactive,"
        "$mod, M, exit,"
        
        # Files & Fenster-Management
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating,"
        "$mod, F, fullscreen,"

        # Fokus wechseln mit Pfeiltasten
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ];

      # Design (CachyOS / Hyprland Standard Stil)
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };
      
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
      };
    };
  };

  # Shell Integration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Verlauf-Einstellungen
    history = {
      size = 10000;
      save = 10000;
      share = true; # Verlauf zwischen Tabs teilen
      path = "${config.home.homeDirectory}/.zsh_history";
    };

    # Aliases für faulere Tipper (NixOS optimiert)
    shellAliases = {
      # NixOS Management
      nix-switch = "sudo nixos-rebuild switch --flake .#kohaku";
      nix-check = "sudo nixos-rebuild dry-activate --flake .#kohaku";
      nix-clean = "sudo nix-collect-garbage -d";
      
      # Komfort
      ls = "ls --color=auto";
      ll = "ls -lah";
      grep = "grep --color=auto";
      ".." = "cd ..";
      
      # Git (weil wir gerade dabei sind)
      gs = "git status";
      ga = "git add .";
      gc = "git commit -m";
      gp = "git push";
    };

    # Vi-Mode (da du Neovim nutzt)
    defaultKeymap = "viins"; 

    initContent= ''
      # Behebt oft Probleme bei SSH-Verbindungen von anderen Shells
      export TERM=xterm-256color 

      # Fix für Backspace in manchen SSH-Clients
      bindkey "^?" backward-delete-char
    '';
  };

  # Dieser State Version Wert darf nicht geändert werden
  home.stateVersion = "24.11";
}

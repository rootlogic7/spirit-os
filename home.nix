{ config, pkgs, inputs, mySshKey, ... }:

{
  # Home Manager braucht diese Infos
  home.username = "haku";
  home.homeDirectory = "/home/haku";
  
  # User-spezifische Pakete
  home.packages = with pkgs; [
    # --- GUI & Tools ---
    ghostty         # Dein Haupt-Terminal
    kitty         # BACKUP: Falls Ghostty mal crasht (kannst du auskommentiert lassen)
    yazi            # File Manager
    wl-clipboard    # Clipboard für Wayland (wichtig für Neovim/Yazi)
    firefox

    # Quickshell
    inputs.quickshell.packages.${pkgs.system}.default
    qt6.qtdeclarative # Hilfreich für QML
    
    # --- Hyprland Ecosystem (NEU & Optimiert) ---
    hyprpolkitagent  # Der neue Auth Agent
    hyprlock         # Screen Locker
    hypridle         # Idle Daemon
    hyprpicker       # Color Picker
    swww             # Wallpaper Daemon mit Transitions

    # --- Utilities ---
    grim             # Screenshot Core
    slurp            # Screenshot Region
    cliphist         # Clipboard History

    # --- CLI Power-Tools (passen zum "Power-User" Thema) ---
    ripgrep         # "rg": Extrem schnelles Grep (nutzt Neovim oft intern)
    fd              # "fd": Schnelleres 'find'
    btop            # Viel schickerer/detaillierterer Task-Manager als htop
    tldr            # Einfachere Man-Pages (z.B. "tldr tar")
    fzf             # Fuzzy Finder (für History-Suche etc.)

    # --- Gaming ---
    mangohud        # Overlay
    # protonup-qt   # Optional: Um Proton-GE einfach zu installieren
  ];

  # --- Hyprland Konfiguration ---
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    
    # Hier passiert die Magie: Wir schreiben die Config direkt in Nix
    settings = {

    # --- AUTORUN ---
      exec-once = [
	"quickshell"                                      # Deine Shell
        "swww-daemon"                                     # Wallpaper Engine
        "systemctl --user start hyprpolkitagent"          # Auth Agent starten
        "hypridle"                                        # Idle Management
        "wl-paste --type text --watch cliphist store"     # Clipboard Text
        "wl-paste --type image --watch cliphist store"    # Clipboard Bilder
      ];

      # --- MONITOR ---
      monitor = [
        "DP-1,3440x1440@100,0x0,auto"
        "HDMI-A-1,1920x1080@100,3440x0,auto"
      ];
      
      # --- ENVIRONMENT ---
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1"
      ];

      # --- INPUT ---
      input = {
        kb_layout = "de";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat"; # Konsistente Mausbewegung (gut für Gaming/Muscle Memory)
        touchpad.natural_scroll = false;
      };
      
      # --- LOOK & FEEL ---
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = true;
      };

      decoration = {
        rounding = 10;
        blur = {
            enabled = true;
            size = 3;
            passes = 3;
            vibrancy = 0.1696;
        };
        shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
            "windows, 1, 5, myBezier"
            "windowsOut, 1, 5, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 5, default"
            "workspaces, 1, 5, default, slide"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      
      # --- NEUE WINDOW RULES SYNTAX ---
      # Format: windowrule = action [args], match:selector
      windowrule = [
        # Polkit Agent (Muss floaten & Fokus haben)
        "float on, match:class hyprpolkitagent"
        "center on, match:class hyprpolkitagent"
        "dim_around on, match:class hyprpolkitagent"
        "stay_focused on, match:class hyprpolkitagent"

        # Standard Dialoge
        "float on, match:title (Open File)"
        "float on, match:title (Select a File)"
        "float on, match:title (Choose wallpaper)"
        "float on, match:title (Save As)"
        "float on, match:title (Library)"
        
        # Tools
        "float on, match:class vlc"
        "float on, match:class kvantummanager"
        "float on, match:class qt5ct"
        "float on, match:class qt6ct"
        "float on, match:class org.kde.ark"
        "float on, match:class com.github.rafostar.Clapper"

        # Steam
        # Friends List muss floaten
        "float on, match:title (Friends List)"
        "float on, match:title (Steam Settings)"
        
        # Gaming Performance
        "immediate on, match:class cs2"  # Tearing erlauben
      ];

      # --- VARIABLES ---
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$fileManager" = "ghostty -e yazi";
      
      # --- KEYBINDINGS ---
      bind = [
        "$mod, Q, exec, $terminal"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating,"
        "$mod, F, fullscreen,"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"
        
        # Utilities
        "$mod, L, exec, hyprlock"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod SHIFT, C, exec, hyprpicker -a"

        # Focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move Active
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
      ];

      # 'bindm' für Maus-Dragging
      bindm = [
        "$mod, mouse:272, movewindow"
	"$mod, mouse:273, resizewindow"
      ];
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
      export TERM=xterm-256color 
      bindkey "^?" backward-delete-char
    '';
  };
  # --- Quickshell Config ---
  xdg.configFile."quickshell".source = ./modules/quickshell;
  # Dieser State Version Wert darf nicht geändert werden
  home.stateVersion = "24.11";
}

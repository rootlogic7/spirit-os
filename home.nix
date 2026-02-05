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
      exec-once = [
        "quickshell"
      ];
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
  # --- Quickshell Config ---
  xdg.configFile."quickshell/shell.qml".text = ''
    //@ using Quickshell 1.0
    //@ using QtQuick 2.15
    //@ using QtQuick.Layouts 1.15
    //@ using Quickshell.Wayland 1.0
    //@ using QtQml 2.15

    ShellRoot {
      // Die Statusbar
      PanelWindow {
        anchors {
          top: true
          left: true
          right: true
        }
        height: 36 // Höhe der Leiste
        color: "#1e1e2e" // Hintergrundfarbe (Catppuccin Mocha Base)

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 15
          anchors.rightMargin: 15

          // Links: System Name / Logo
          Text {
            text: "  KOHAKU"
            color: "#89b4fa" // Blau
            font.bold: true
            font.pixelSize: 14
          }

          // Mitte: Spacer (drückt alles nach außen)
          Item { Layout.fillWidth: true }

          // Rechts: Uhrzeit
          Text {
            id: time
            color: "#cdd6f4" // Weiß
            font.pixelSize: 14

            // Timer für Sekunden-Update
            Timer {
              interval: 1000; running: true; repeat: true
              onTriggered: time.text = Qt.formatTime(new Date(), "hh:mm")
            }
            Component.onCompleted: time.text = Qt.formatTime(new Date(), "hh:mm")
          }
        }
      }
    }
  '';
  # Dieser State Version Wert darf nicht geändert werden
  home.stateVersion = "24.11";
}

{ pkgs, ... }:

{
  # GTK Theming (für Gnome Apps, File Dialoge, etc.)
  gtk = {
    enable = true;
    
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "standard";
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };

    cursorTheme = {
      name = "catppuccin-mocha-mauve-cursors";
      package = pkgs.catppuccin-cursors;
      size = 24;
    };
    
    # GTK 3 & 4 Konfiguration
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Mauszeiger auch für Hyprland selbst setzen (wichtig für Konsistenz)
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "catppuccin-mocha-mauve-cursors";
    package = pkgs.catppuccin-cursors;
    size = 24;
  };
  
  # QT Theming an GTK anpassen (damit QT Apps auch dunkel sind)
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "gtk2";
  };
}

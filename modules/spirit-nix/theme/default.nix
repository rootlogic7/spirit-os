{ lib, config, ... }:

with lib; {
  # Wir definieren einen eigenen "Namespace" für deine Variablen
  options.spirit.theme = {
    
    wallpaper = mkOption { 
      type = types.path; 
      default = ./wallpaper.png; 
      description = "Das globale Hintergrundbild"; 
    };

    # --- Fonts and Fontsize ---
    fonts = {
      main = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Die primäre Schriftart für UI, Bars und Terminals";
      };
      
      size = mkOption {
        type = types.int;
        default = 12;
        description = "Die Basis-Schriftgröße für das Terminal";
      };
    };

    colors = {
      # --- Base Colors ---
      base     = mkOption { type = types.str; default = "1e1e2e"; description = "Dunkelster Hintergrund (z.B. Terminals)"; };
      mantle   = mkOption { type = types.str; default = "181825"; description = "Hintergrund für UI-Elemente"; };
      crust    = mkOption { type = types.str; default = "11111b"; description = "Tiefster Hintergrund (Bars/Panels)"; };
      
      # --- Surfaces (Highlights & Overlays) ---
      surface0 = mkOption { type = types.str; default = "313244"; };
      surface1 = mkOption { type = types.str; default = "45475a"; description = "Hover States"; };
      surface2 = mkOption { type = types.str; default = "585b70"; };

      # --- Typography ---
      text     = mkOption { type = types.str; default = "cdd6f4"; description = "Standard Textfarbe"; };
      subtext0 = mkOption { type = types.str; default = "a6adc8"; description = "Sekundärer/Gedimmter Text"; };

      # --- Accents ---
      accent   = mkOption { type = types.str; default = "cba6f7"; description = "Haupt-Akzentfarbe (Mauve)"; };
      blue     = mkOption { type = types.str; default = "89b4fa"; };
      green    = mkOption { type = types.str; default = "a6e3a1"; };
      red      = mkOption { type = types.str; default = "f38ba8"; };
      yellow   = mkOption { type = types.str; default = "f9e2af"; };
      peach    = mkOption { type = types.str; default = "fab387"; };
      teal     = mkOption { type = types.str; default = "94e2d5"; };
    };
  };
}

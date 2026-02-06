{ config, pkgs, inputs, vars, ... }:

{
  imports = [
    ../../modules/spirit-nix/default.nix
  ];

  home.username = vars.user;
  home.homeDirectory = "/home/${vars.user}";

  # Pakete: Wir übernehmen die gleichen wie am Desktop
  home.packages = with pkgs; [
    firefox
    yazi
    vesktop
    mangohud
    obsidian
    # Tools für Laptop-Power-Management
    brightnessctl # Für Bildschirmhelligkeit
  ];

  # Git Identität
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "haku";
        email = "rootlogic7@proton.me";
      };
      init.defaultBranch = "main";
    };
  };

  # --- Hyprland Laptop Config ---
  wayland.windowManager.hyprland.settings = {
    # Dynamische Monitorkonfiguration (Auto)
    monitor = [ ", preferred, auto, 1" ];

    # Touchpad Gesten & Einstellungen
    input = {
      sensitivity = 0.2; # Etwas schnelleres Touchpad
      touchpad = {
        natural_scroll = true;
        scroll_factor = 0.5;
      };
    };
    
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
    };
    
    # Keybindings für Helligkeit und Lautstärke (FN-Tasten)
    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];
    
    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];
  };

  home.stateVersion = "24.11";
}

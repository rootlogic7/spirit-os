{ config, pkgs, vars, ... }:

{
  # --- Nix Einstellungen ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    
    # Binary Caches für schnellere Builds
    substituters = [
      "https://nix-community.cachix.org"
      "https://chaotic-nyx.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "chaotic-nyx.cachix.org-1:dHw3kV0d+x7O25psfwbP6tV76r4ivI8pshwlSwP63cs="
    ];
  };

  # Garbage Collection (Automatisch aufräumen)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  # --- Basis Pakete ---
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    pciutils
    fastfetch
    sops
    # Der Wrapper MUSS großgeschrieben sein, um sysc-greet abzufangen!
    (writeShellScriptBin "Hyprland" ''
      # Loop-Schutz: Falls start-hyprland intern wieder "Hyprland" aufruft
      if [ "$HYPRLAND_WRAPPER_ACTIVE" = "1" ]; then
        exec ${pkgs.hyprland}/bin/Hyprland "$@"
      else
        export HYPRLAND_WRAPPER_ACTIVE=1
        exec start-hyprland "$@"
      fi
    '')
  ];

  # --- Editor ---
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # --- Locale & Zeit ---
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # --- Security ---
  # Basis SSH Config (Host Keys bleiben im Host-File)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

}

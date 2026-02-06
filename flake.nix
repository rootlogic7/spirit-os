{
  description = "Spirit-OS (NixOS) - Modular Configuration";

  inputs = {
    # --- Core ---
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # --- Kernel & Performance ---
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- User Management ---
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Secrets ---
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Custom Modules ---
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    
    # Globale Variablen
    vars = {
      user = "haku";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMD0q9gEM7isC6P98pLnNcEaoGP88toK3z+AqU9Gsx4 rootlogic7@proton.me";
    };
    # Helper-Funktion für System-Erstellung (jetzt mit optionalem homeConfig Argument)
    mkSystem = { hostname, user, homeConfig ? ./users/${user}/home.nix }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs vars; };
      modules = [
        ./hosts/${hostname}/default.nix
        ./modules/core/default.nix
        inputs.chaotic.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs vars; };
          # Lädt die übergebene Home-Config (oder den Default)
          home-manager.users.${user} = import homeConfig;
        }
      ];
    };
  in {
    nixosConfigurations = {
      # Maschine: Kohaku
      kohaku = mkSystem { 
        hostname = "kohaku"; 
        user = "haku"; 
      };
      chihiro = mkSystem {
        hostname = "chihiro";
        user = "haku";
        homeConfig = ./users/haku/home-chihiro.nix;
      };
    };
  };
}

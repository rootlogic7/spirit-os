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

    # Helper-Funktion für System-Erstellung
    mkSystem = { hostname, user }: nixpkgs.lib.nixosSystem {
      inherit system;
      # Übergibt inputs und vars an alle Module
      specialArgs = { inherit inputs vars; };
      modules = [
        # 1. Host-Spezifische Konfiguration
        ./hosts/${hostname}/default.nix
        
        # 2. Basis-System (immer dabei)
        ./modules/core/default.nix

        # 3. Kernel Optimierungen (Chaotic Nyx)
        inputs.chaotic.nixosModules.default
        
        # 4. Secrets Management
        inputs.sops-nix.nixosModules.sops

        # 5. Home Manager Integration
        inputs.home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs vars; };
          
          # Lädt die Home-Config des angegebenen Users
          home-manager.users.${user} = import ./users/${user}/home.nix;
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
    };
  };
}

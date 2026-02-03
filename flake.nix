{
  description = "Kohaku NixOS Flake";

  inputs = {
    # NixOS Unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Chaotic Nyx (CachyOS Kernel)
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager (Verwaltet Dotfiles & User-Programme)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Sops Secret Management
    sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.kohaku = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.chaotic.nixosModules.default
        ./configuration.nix
        
        # Home Manager Modul direkt einbinden
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          # FIX: Wenn Dateien schon existieren, benenne sie um (.backup), statt abzubrechen
          home-manager.backupFileExtension = "backup";
          
          # Hier definieren wir, dass der User 'haku' die Datei home.nix nutzt
          home-manager.users.haku = import ./home.nix;
        }
      ];
    };
  };
}

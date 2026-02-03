{
  description = "Kohaku NixOS Flake";

  inputs = {
    # Offizielles NixOS Repository (Unstable für aktuellste Software/Kernel)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Chaotic Nyx (CachyOS Kernel, Gaming Optimierungen)
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      # WICHTIG: Nutze das gleiche nixpkgs wie das System, um Fehler zu vermeiden!
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.kohaku = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.chaotic.nixosModules.default

        ./configuration.nix
        { nixpkgs.config.allowUnfree = true; }
      ];
    };
  };
}

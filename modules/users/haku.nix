{ config, pkgs, ... }:

{
  users.users.haku = { 
    isNormalUser = true;
    description = "Haku";
    hashedPasswordFile = config.sops.secrets."haku-password".path;
    # initialPassword = "haku";
    extraGroups = [ "networkmanager" "wheel" "video" "gamemode" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6FGcKzp9lwFTWQXNNLB1xJC07rTWJeK2GN0J9mcjqg rootlogic7@proton.me" ];
  };

  # Zsh auf Systemebene aktivieren, damit Login funktioniert
  programs.zsh.enable = true;

  # --- SOPS USER SECRETS ---
  sops.secrets."github-ssh-key" = {
    path = "/home/haku/.ssh/id_ed25519";
    owner = "config.users.users.haku.name";
    mode = "0400";
  };
}

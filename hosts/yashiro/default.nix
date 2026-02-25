{ config, pkgs, lib, ... }:

{
  # --- Bootloader ---
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # --- Basis-System ---
  networking.hostName = "yashiro";

  # --- Boot & Hardware (Die Pi-Spezialitäten) ---
  boot.kernelParams = [ "console=tty0" ];
  boot.initrd.availableKernelModules = [ 
    "xhci_pci" 
    "pcie_brcmstb"       # Der PCIe-Bus fürs Netzwerk
    "reset-raspberrypi"
    "vc4"                # Der Grafiktreiber (Damit das Bild nach "Starting kernel..." bleibt)
  ];

  # --- Storage & Impermanence ---
  # Zwingend erforderlich, damit SOPS den SSH-Key beim Booten findet!
  fileSystems."/persist".neededForBoot = true;

  # --- Nix & Remote Deployments ---
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # --- Secrets & SOPS ---
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets."haku-password".neededForUsers = true;
  };

  # --- Notfall-Hintertür (Optional) ---
  # Da SOPS jetzt richtig konfiguriert ist, sollte dein Passwort endlich funktionieren.
  # Falls du auf Nummer sicher gehen willst, lass diese Zeile für den ersten 
  # Bootvorgang noch einkommentiert, um dich nicht wieder aus sudo auszusperren:
  # security.sudo.wheelNeedsPassword = false;

  # --- Der isolierte Server-User "haku" ---
  users.users.haku = {
    isNormalUser = true;
    description = "Haku";
    # SOPS verknüpfen:
    hashedPasswordFile = config.sops.secrets."haku-password".path;
    # initialPassword = "susuwatari";
    # Nur die absolut überlebenswichtigen Gruppen (sudo):
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOZIedSYR0vz3AWo2pykzFiHFCDfKuswPluT4puCsTD6 haku@kohaku"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHa4bO683OVwOVR9sc2aGDT/OI0A1TAkaPUQ6rhnwmqQ haku@shikigami"
    ];
  };

  # Zsh auf Systemebene aktivieren, damit der Login in die Shell klappt
  programs.zsh.enable = true;

  system.stateVersion = "25.11";
}

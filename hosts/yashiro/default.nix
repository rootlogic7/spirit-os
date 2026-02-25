{ config, pkgs, lib, ... }:

{
  # --- Basis-System ---
  networking.hostName = "yashiro";

  # --- Boot & Hardware (Die Pi-Spezialitäten) ---
  
  # Zwingt den Kernel, seine Ausgaben über HDMI auf dem Monitor anzuzeigen.
  boot.kernelParams = [ "console=tty0" ];

  # Die absolut überlebenswichtigen Treiber für die Vor-Start-Phase (initrd):
  boot.initrd.availableKernelModules = [ 
    "xhci_pci" 
    "pcie_brcmstb"       # Der PCIe-Bus (Ohne den ist der LAN-Chip blind und taub!)
    "reset-raspberrypi"
    "vc4"                # Der Grafiktreiber (Damit das Bild nach "Starting kernel..." bleibt)
  ];

  # --- Storage & Impermanence ---
  # EXTREM WICHTIG FÜR SOPS & IMPERMANENCE:
  # Da SOPS die Passwörter sehr früh im Boot-Prozess entschlüsseln muss, 
  # muss die Partition mit deinen persistenten Schlüsseln zwingend rechtzeitig gemountet sein!
  fileSystems."/persist".neededForBoot = true;

  # --- Nix & Remote Deployments ---
  
  # Erlaubt Admins (die Gruppe @wheel, in der haku ist) das direkte 
  # Bauen und Deployen über SSH (nixos-rebuild switch ... --target-host).
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # --- Secrets & SOPS (Der Schlüssel zur Festung) ---
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # DER IMPERMANENCE-FIX:
    # Da das normale /etc/ssh flüchtig ist, muss SOPS den echten, dauerhaften 
    # Schlüssel aus deinem Persistenz-Ordner lesen!
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    
    # Zwingt SOPS, diese Datei extrem früh zu entschlüsseln, noch BEVOR 
    # NixOS den User 'haku' anlegt und ihm das Passwort zuweisen will.
    secrets."haku-password".neededForUsers = true;
  };

  # --- Notfall-Hintertür (Optional) ---
  # Da SOPS jetzt richtig konfiguriert ist, sollte dein Passwort endlich funktionieren.
  # Falls du auf Nummer sicher gehen willst, lass diese Zeile für den ersten 
  # Bootvorgang noch einkommentiert, um dich nicht wieder aus sudo auszusperren:
  # security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "25.11";
}

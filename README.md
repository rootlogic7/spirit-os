# 👻 Spirit-OS

Willkommen im Monorepo für meine NixOS-Infrastruktur. Dieses Repository verwaltet meine gesamte PC-Flotte und enthält meine eigene, modulare Linux-Distribution "Spirit-Nix".

## 📂 Struktur

Die Konfiguration folgt dem Nix Flakes Ansatz und ist modular aufgebaut:

o├── flake.nix                   # Einstiegspunkt & Definition der Hosts

o├── flake.lock                  # Gepinnte Versionen (Reproduzierbarkeit)

o├── hosts/                      # Maschinenspezifische Konfigurationen

o│ooooo├── kohaku/                 # Haupt-Workstation

o│ooooo└── (chihiro)/              # (Zukünftiger Laptop)

o├── modules/                    # Wiederverwendbare Module

o│ooooo├── core/                   # Basis-System (für ALLE Rechner)

o│ooooo├── spirit-nix/             # 🌟 Meine Custom Distro (Theme, Hyprland, Shell)

o│ooooo└── hardware/               # Hardware-Module (Nvidia, ZFS etc.)

o└── users/                      # Benutzer-Definitionen

o ooooo├── haku/                   # Mein User (lädt Spirit-Nix)

o ooooo└── (user2)/               # User

## 🚀 Workflow Cheatsheet

Da Flakes nur Dateien sehen, die Git bekannt sind, ist der Workflow strikt:

### 1. Änderungen anwenden (Der "Daily Loop")
´´´
# 1. Änderungen stagen (WICHTIG!)
git add .

# 2. Testen (Dry Run - baut, aber aktiviert nicht)
sudo nixos-rebuild dry-activate --flake .#kohaku

# 3. Anwenden (Switch)
sudo nixos-rebuild switch --flake .#kohaku
´´´

### 2. System-Updates (Pakete aktualisieren)
´´
# 1. flake.lock aktualisieren (lädt neuste Versionen von nixpkgs/chaotic)
nix flake update

# 2. System neu bauen
sudo nixos-rebuild switch --flake .#kohaku

# 3. Lockfile committen
git commit -m "chore: update system packages" flake.lock
´´

### 3. Aufräumen (Garbage Collection)
´´
# Alte Generationen löschen und Store optimieren
nix-collect-garbage -d
´´

## 🛠 Verwaltung & Szenarien

### Einen neuen Host hinzufügen (z.B. "chihiro")

1. Verzeichnis hosts/chihiro erstellen.

2. hosts/kohaku/default.nix dorthin kopieren und anpassen (Bootloader, Hostname, Imports).

3. hardware-configuration.nix vom Zielgerät generieren und in den Ordner legen.

4. In flake.nix einen neuen Eintrag unter nixosConfigurations hinzufügen:
´´
chihiro = mkSystem { hostname = "chihiro"; user = "haku"; };
´´

5. Installieren: nixos-rebuild switch --flake .#chihiro

### Einen neuen User hinzufügen (z.B. "bruder")

1. modules/users/bruder.nix erstellen (System-User Definition).

2. users/bruder/home.nix erstellen (Home-Manager Config).

3. In users/bruder/home.nix die Distro importieren:
´´´
imports = [ ../../modules/spirit-nix/default.nix ];
´´

### Secrets verwalten (Sops)

- Passwörter liegen verschlüsselt in secrets/secrets.yaml.

- Bearbeiten: sops secrets/secrets.yaml

    1. Neuen Host berechtigen:

    2. SSH Public Key des Hosts in .sops.yaml hinzufügen.

Keys neu verschlüsseln: sops updatekeys secrets/secrets.yaml

## 🎨 Spirit-Nix Distribution

### Meine persönliche "Distro" lebt in modules/spirit-nix. Sie beinhaltet:

- Desktop: Hyprland (High Performance Config)

- UI: Quickshell (Custom Bars & Widgets in QML)

- Shell: Zsh + Starship + CLI Tools (eza, bat, fzf)

- Theme: Globales Styling

Änderungen am Design sollten immer in modules/spirit-nix gemacht werden, damit alle User davon profitieren.

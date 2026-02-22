# 👻 Spirit-OS: Installation Guide

Dieser Guide beschreibt den vollständigen Installationsprozess für einen neuen (oder zu formatierenden) Host innerhalb der Spirit-OS Architektur.

Das Setup nutzt ZFS Impermanence (Erase Your Darlings), SOPS-Nix für Secrets und Disko für die automatische Partitionierung.

**⚠️ Achtung**: Disko formatiert die in der disko.nix angegebenen Laufwerke komplett! Nicht aufgeführte Laufwerke (z. B. bestehende ZFS-RAIDs) werden sicher ignoriert und bleiben erhalten.


## Phase 0: Vorbereitung (Im laufenden System)

Bevor der Rechner formatiert wird, müssen die Configs auf den neuesten Stand gebracht werden.

1. Falls es sich um eine Neuinstallation bestehender Hardware handelt: system.stateVersion in der entsprechenden hosts/<hostname>/default.nix auf das aktuelle Release anheben (falls gewünscht).

2. Alle Änderungen committen und auf GitHub pushen.

3. Sicherstellen, dass ein zweites Gerät (z.B. Laptop) oder der SOPS Admin-Key griffbereit ist, um gleich die Secrets für den neuen Host zu berechtigen.


## Phase 1: Live-Umgebung & Vorbereitung

1. Boote vom offiziellen NixOS Live-USB-Stick.

2. Öffne ein Terminal und werde zu Root:

    ´´´bash
    sudo -i
    ´´´

3. Lege das LUKS-Passwort für die Festplattenverschlüsselung temporär im RAM ab:

    '''
    echo -n "DEIN_FESTPLATTEN_PASSWORT" > /tmp/secret.key
    '''

4. Klone das Spirit-OS Repository in den flüchtigen Arbeitsspeicher:

    '''
    git clone [https://github.com/DEIN_GITHUB_NAME/spirit-os.git](https://github.com/DEIN_GITHUB_NAME/spirit-os.git) /tmp/spirit-os
    cd /tmp/spirit-os
    '''


## Phase 2: Partitionierung & ZFS Setup (Disko)

Führe Disko für den spezifischen Host aus (ersetze kohaku ggf. durch deinen Hostnamen).
Dieser Schritt formatiert die definierten Laufwerke, erstellt die ZFS-Pools, legt die initialen blank-Snapshots für Impermanence an und mountet alles unter /mnt.

   '''
   nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/kohaku/disko.nix
   '''


## Phase 3: Host-Identität & SSH-Keys (Automatisiert)

Das frisch formatierte System benötigt eine persistente machine-id und einen eigenen SSH-Host-Key, damit SOPS später die Passwörter entschlüsseln kann.

Führe das beiliegende Skript aus:

   '''
   ./scripts/install-keys.sh
   '''

**👉 WICHTIG**: Kopiere den am Ende in Grün ausgegebenen age1... String! Das ist die Identität des neuen Systems.


## Phase 4: SOPS-Tresor updaten (Der Henne-Ei-Fix)

Da das Live-System keine GitHub-Rechte hat und die Secrets noch nicht lesen kann, muss das Update von einem bereits berechtigten Gerät (oder mit dem Admin-Key) erfolgen.

Auf deinem Zweitgerät (z.B. Laptop):

1. Öffne die .sops.yaml im Repository.

2. Trage den in Phase 3 kopierten age1... Key beim entsprechenden Host ein.

3. Führe das SOPS-Update aus, um die Secrets für den neuen Key zugänglich zu machen:

    '''
    sops updatekeys secrets/secrets.yaml
    '''

4. Änderungen committen und pushen:

    '''
    git add .
    git commit -m "chore: update host ssh key for fresh install"
    git push
    '''


## Phase 5: Finale System-Installation

Zurück am Live-USB-Stick des zu installierenden Rechners:

1. Ziehe dir die aktualisierte SOPS-Datei aus dem Repo:

    '''
    git pull
    '''

2. Starte die NixOS-Installation. (Wir verbieten absichtlich ein lokales Root-Passwort, da das System über sudo und SOPS gesichert ist!)

    '''
    nixos-install --flake .#kohaku --no-root-passwd
    '''


## Phase 6: Reboot & Enjoy

1. Wenn die Installation abgeschlossen ist:

    '''
    reboot
    '''

2. Ziehe den USB-Stick ab.

3. Beim Hochfahren fragt das System nach den LUKS-Passwörtern (auch für eventuell bestehende, nicht-formatierte ZFS-RAIDs, sofern in der default.nix deklariert).

4. SOPS liest den neuen SSH-Key, entschlüsselt das User-Passwort und das System ist einsatzbereit!

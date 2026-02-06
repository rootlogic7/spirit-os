#!/usr/bin/env bash
set -e

# DISK DEFINIEREN (Prüfen mit lsblk!)
DISK="/dev/nvme0n1"

echo "WARNUNG: Alle Daten auf $DISK werden gelöscht!"
echo "Drücke STRG+C zum Abbrechen oder Enter zum Fortfahren..."
read

# 1. Partitionierung (Boot + LUKS)
# sgdisk zap (alles löschen)
sgdisk -Z $DISK
# Partition 1: 1GB Boot (Typ ef00)
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"disk-main-ESP" $DISK
# Partition 2: Rest für LUKS (Typ 8309 - Linux LUKS)
sgdisk -n 2:0:0 -t 2:8309 -c 2:"disk-main-luks" $DISK

# 2. Verschlüsselung (LUKS)
echo "Erstelle LUKS Container..."
cryptsetup luksFormat /dev/disk/by-partlabel/disk-main-luks
echo "Öffne LUKS Container..."
cryptsetup luksOpen /dev/disk/by-partlabel/disk-main-luks crypt_root

# 3. ZFS Pool erstellen
# Wir erstellen rpool direkt im entschlüsselten Mapper
zpool create -O mountpoint=legacy -O atime=off -O xattr=sa -O acltype=posixacl -O compression=lz4 rpool /dev/mapper/crypt_root

# 4. Datasets erstellen (wie in hardware-configuration.nix definiert)
zfs create rpool/root
zfs create rpool/home
zfs create rpool/nix

# 5. Mounten
mount -t zfs rpool/root /mnt
mkdir -p /mnt/{home,nix,boot}
mount -t zfs rpool/home /mnt/home
mount -t zfs rpool/nix /mnt/nix

# Boot Partition formatieren und mounten
mkfs.vfat -n BOOT /dev/disk/by-partlabel/disk-main-ESP
mount /dev/disk/by-partlabel/disk-main-ESP /mnt/boot

echo "Fertig! Du kannst jetzt installieren."

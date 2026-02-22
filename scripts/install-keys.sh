#!/usr/bin/env bash
set -e

echo -e "\n\033[1;34m[1/3] Erstelle Ordnerstruktur & machine-id...\033[0m"
mkdir -p /mnt/persist/etc/ssh
systemd-machine-id-setup --print > /mnt/persist/etc/machine-id
echo "✅ machine-id erstellt."

echo -e "\n\033[1;34m[2/3] Generiere neuen SSH Host-Key...\033[0m"
ssh-keygen -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key -N "" -q
echo "✅ SSH-Key erstellt."

echo -e "\n\033[1;34m[3/3] Übersetze Key für SOPS...\033[0m"
AGE_KEY=$(nix-shell -p ssh-to-age --run "ssh-to-age < /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub")

echo -e "\n===================================================================="
echo -e "🎉 \033[1;32mFERTIG! HIER IST DEIN NEUER HOST-KEY:\033[0m"
echo -e "\n\033[1;32m$AGE_KEY\033[0m\n"
echo -e "👉 Füge diesen Key jetzt auf Shikigami in die '.sops.yaml' ein,"
echo -e "👉 mache ein 'sops updatekeys secrets/secrets.yaml',"
echo -e "👉 pushe es auf GitHub und mache hier im Live-System ein 'git pull'."
echo -e "====================================================================\n"

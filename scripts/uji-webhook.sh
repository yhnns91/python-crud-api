#!/usr/bin/env bash
# Tahap 10.4 dan 11: membuat commit kecil lalu push ke GitHub untuk memicu webhook.
#   bash scripts/uji-webhook.sh
#   bash scripts/uji-webhook.sh "test: webhook saat ngrok mati"
PESAN="${1:-test: trigger GitHub webhook}"
WAKTU=$(date '+%Y-%m-%d %H:%M:%S')
echo "Webhook test $WAKTU" >> README.md
echo -e "\033[0;90m\$ git add README.md && git commit -m \"$PESAN\" && git push origin main\033[0m"
git add README.md && git commit -m "$PESAN" && git push origin main
echo
echo -e "\033[1;32mPush selesai pukul $WAKTU. Buka Jenkins: build baru harus muncul otomatis tanpa Build Now.\033[0m"

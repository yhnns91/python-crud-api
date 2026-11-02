#!/usr/bin/env bash
# Tahap 9 (Tugas C): bukti persistensi data. Jalankan dari folder python-crud-api.
#   SEBELUM redeploy : bash scripts/persistensi.sh --buat-pesan   (Screenshot 7.1)
#   lalu klik Build Now di Jenkins dan tunggu sampai sukses      (Screenshot 7.2)
#   SESUDAH redeploy : bash scripts/persistensi.sh                (Screenshot 7.3)
export MSYS_NO_PATHCONV=1
BASE="http://localhost:5000"
C='\033[1;36m'; N='\033[0m'

if [ "$1" = "--buat-pesan" ]; then
    echo -e "${C}>>> Membuat dua pesan${N}"
    curl -s -X POST "$BASE/messages" -H 'Content-Type: application/json' -d '{"message":"Pesan pertama dari praktikum"}'; echo
    curl -s -X POST "$BASE/messages" -H 'Content-Type: application/json' -d '{"message":"Pesan kedua"}'; echo
fi

echo
echo -e "${C}>>> Kontainer API saat ini (perhatikan CONTAINER ID)${N}"
docker ps --filter 'name=^/production-api-container$' --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}'

echo
echo -e "${C}>>> Isi data (GET /messages)${N}"
curl -s "$BASE/messages"; echo

echo
echo -e "${C}>>> Named volume${N}"
docker volume inspect production-api-data --format 'Volume {{.Name}}, dibuat {{.CreatedAt}}, lokasi {{.Mountpoint}}'

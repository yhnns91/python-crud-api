#!/usr/bin/env bash
# Tahap 8: uji endpoint API. Jalankan dari folder python-crud-api, satu bagian per screenshot:
#   bash scripts/uji-api.sh 1   (Screenshot 6.1: health + read)
#   bash scripts/uji-api.sh 2   (Screenshot 6.2: create + input kosong)
#   bash scripts/uji-api.sh 3   (Screenshot 6.3: delete valid + delete 999)
BAGIAN="${1:-0}"
BASE="http://localhost:5000"
C='\033[1;36m'; D='\033[0;90m'; N='\033[0m'

uji() { echo; echo -e "${C}>>> $1  (diharapkan: $2)${N}"; echo -e "${D}\$ $3${N}"; }

[ -f contoh-request/pesan1.json ] || { echo "GAGAL: jalankan skrip ini dari folder python-crud-api."; exit 1; }

if [ "$BAGIAN" = 0 ] || [ "$BAGIAN" = 1 ]; then
    uji "Health" "HTTP 200, status active" "curl -i $BASE/health"
    curl -i "$BASE/health"; echo
    uji "Read" "JSON messages dan total" "curl -s $BASE/messages"
    curl -s "$BASE/messages"; echo
fi

if [ "$BAGIAN" = 0 ] || [ "$BAGIAN" = 2 ]; then
    uji "Create" "HTTP 201, ada created_at" "curl -i -X POST $BASE/messages -H 'Content-Type: application/json' -d '{\"message\":\"Pesan pertama dari praktikum\"}'"
    curl -i -X POST "$BASE/messages" -H 'Content-Type: application/json' -d '{"message":"Pesan pertama dari praktikum"}'; echo
    uji "Input kosong" "HTTP 400" "curl -i -X POST $BASE/messages -H 'Content-Type: application/json' -d '{\"message\":\"\"}'"
    curl -i -X POST "$BASE/messages" -H 'Content-Type: application/json' -d '{"message":""}'; echo
fi

if [ "$BAGIAN" = 0 ] || [ "$BAGIAN" = 3 ]; then
    uji "Delete valid" "HTTP 200, item terhapus" "curl -i -X DELETE '$BASE/messages?index=0'"
    curl -i -X DELETE "$BASE/messages?index=0"; echo
    uji "Delete index tidak ada" "HTTP 404" "curl -i -X DELETE '$BASE/messages?index=999'"
    curl -i -X DELETE "$BASE/messages?index=999"; echo
fi

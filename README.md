# python-crud-api

Python REST API sederhana untuk praktikum CI/CD dengan Jenkins, GitHub, Docker, dan ngrok.

## Endpoint

| Method | Path | Fungsi |
|---|---|---|
| GET | `/health` | Cek status layanan |
| GET | `/messages` | Tampilkan semua pesan |
| POST | `/messages` | Tambah pesan (body JSON: `{"message": "..."}`) |
| DELETE | `/messages?index=N` | Hapus pesan ke-N (mulai dari 0) |

Data disimpan di `/var/lib/backend_data/messages.json`, yang dipasang ke Docker named volume `production-api-data` agar tetap ada walaupun kontainer diganti.

## Pipeline Jenkins

1. Checkout Code
2. Code Syntax Verification (`python3 -m py_compile app.py`)
3. Build Docker Image (tag: `BUILD_NUMBER`, commit SHA, dan `latest`)
4. Automated Deployment (kontainer `production-api-container`, port 5000, volume `production-api-data`)
5. Health Check (curl dari Jenkins + status Docker HEALTHCHECK)

Pipeline otomatis berjalan setiap ada push ke branch `main` melalui GitHub webhook (via ngrok).

## Image Jenkins kustom

Folder `jenkins/` berisi Dockerfile image Jenkins yang sudah dilengkapi Python 3 dan Docker CLI, karena image `jenkins/jenkins` bawaan tidak memiliki keduanya.

## Skrip bantu

Folder `scripts/` berisi skrip untuk menyiapkan Jenkins, menguji API, membuktikan persistensi, dan memicu webhook, dalam versi Bash (`.sh`, untuk Git Bash) dan PowerShell (`.ps1`). Contoh di Git Bash: `bash scripts/siapkan-jenkins.sh`.

## Uji cepat (Git Bash, dari folder proyek)

```
curl -i http://localhost:5000/health
curl -i -X POST http://localhost:5000/messages -H 'Content-Type: application/json' -d '{"message":"Pesan pertama dari praktikum"}'
curl -s http://localhost:5000/messages
curl -i -X DELETE 'http://localhost:5000/messages?index=0'
```
Webhook test 2026-11-03 05:05:16
Webhook test 2026-11-03 05:11:19

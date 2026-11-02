# Tahap 8: uji endpoint API. Jalankan dari folder python-crud-api, satu bagian per screenshot:
#   powershell -ExecutionPolicy Bypass -File .\scripts\uji-api.ps1 -Bagian 1   (Screenshot 6.1: health + read)
#   powershell -ExecutionPolicy Bypass -File .\scripts\uji-api.ps1 -Bagian 2   (Screenshot 6.2: create + input kosong)
#   powershell -ExecutionPolicy Bypass -File .\scripts\uji-api.ps1 -Bagian 3   (Screenshot 6.3: delete valid + delete 999)
param([int]$Bagian = 0)

$base = "http://localhost:5000"
function Uji($judul, $harap, $perintah) {
    Write-Host ""
    Write-Host ">>> $judul  (diharapkan: $harap)" -ForegroundColor Cyan
    Write-Host "PS> $perintah" -ForegroundColor DarkGray
}

if (-not (Test-Path ".\contoh-request\pesan1.json")) {
    Write-Host "GAGAL: jalankan skrip ini dari folder python-crud-api." -ForegroundColor Red
    exit 1
}

if ($Bagian -eq 0 -or $Bagian -eq 1) {
    Uji "Health" "HTTP 200, status active" "curl.exe -i $base/health"
    curl.exe -i "$base/health"; Write-Host ""
    Uji "Read" "JSON messages dan total" "curl.exe -s $base/messages"
    curl.exe -s "$base/messages"; Write-Host ""
}

if ($Bagian -eq 0 -or $Bagian -eq 2) {
    Uji "Create" "HTTP 201, ada created_at" "curl.exe -i -X POST $base/messages -H `"Content-Type: application/json`" --data-binary `"@contoh-request/pesan1.json`""
    curl.exe -i -X POST "$base/messages" -H "Content-Type: application/json" --data-binary "@contoh-request/pesan1.json"; Write-Host ""
    Uji "Input kosong" "HTTP 400" "curl.exe -i -X POST $base/messages -H `"Content-Type: application/json`" --data-binary `"@contoh-request/pesan-kosong.json`""
    curl.exe -i -X POST "$base/messages" -H "Content-Type: application/json" --data-binary "@contoh-request/pesan-kosong.json"; Write-Host ""
}

if ($Bagian -eq 0 -or $Bagian -eq 3) {
    Uji "Delete valid" "HTTP 200, item terhapus" "curl.exe -i -X DELETE `"$base/messages?index=0`""
    curl.exe -i -X DELETE "$base/messages?index=0"; Write-Host ""
    Uji "Delete index tidak ada" "HTTP 404" "curl.exe -i -X DELETE `"$base/messages?index=999`""
    curl.exe -i -X DELETE "$base/messages?index=999"; Write-Host ""
}

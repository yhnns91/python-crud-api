# Tahap 9 (Tugas C): bukti persistensi data. Jalankan dari folder python-crud-api.
#   SEBELUM redeploy : powershell -ExecutionPolicy Bypass -File .\scripts\persistensi.ps1 -BuatPesan   (Screenshot 7.1)
#   lalu klik Build Now di Jenkins dan tunggu sampai sukses (Screenshot 7.2)
#   SESUDAH redeploy : powershell -ExecutionPolicy Bypass -File .\scripts\persistensi.ps1              (Screenshot 7.3)
param([switch]$BuatPesan)

$base = "http://localhost:5000"

if ($BuatPesan) {
    Write-Host ">>> Membuat dua pesan" -ForegroundColor Cyan
    curl.exe -s -X POST "$base/messages" -H "Content-Type: application/json" --data-binary "@contoh-request/pesan1.json"; Write-Host ""
    curl.exe -s -X POST "$base/messages" -H "Content-Type: application/json" --data-binary "@contoh-request/pesan2.json"; Write-Host ""
}

Write-Host ""
Write-Host ">>> Kontainer API saat ini (perhatikan CONTAINER ID)" -ForegroundColor Cyan
docker ps --filter "name=^/production-api-container$" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"

Write-Host ""
Write-Host ">>> Isi data (GET /messages)" -ForegroundColor Cyan
curl.exe -s "$base/messages"; Write-Host ""

Write-Host ""
Write-Host ">>> Named volume" -ForegroundColor Cyan
docker volume inspect production-api-data --format "Volume {{.Name}}, dibuat {{.CreatedAt}}, lokasi {{.Mountpoint}}"

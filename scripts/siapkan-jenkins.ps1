# Menyiapkan Jenkins untuk praktikum CI/CD (Tahap 0.3 dan 5.1 sampai 5.4).
# Jalankan dari folder python-crud-api:
#   powershell -ExecutionPolicy Bypass -File .\scripts\siapkan-jenkins.ps1

function Langkah($teks) { Write-Host ""; Write-Host "=== $teks ===" -ForegroundColor Cyan }
function Gagal($teks) { Write-Host ""; Write-Host "GAGAL: $teks" -ForegroundColor Red; exit 1 }

if (-not (Test-Path ".\jenkins\Dockerfile")) {
    Gagal "Jalankan skrip ini dari folder python-crud-api (folder yang berisi Jenkinsfile)."
}

Langkah "1. Cek Docker"
docker info --format "{{.ServerVersion}}" | Out-Null
if ($LASTEXITCODE -ne 0) { Gagal "Docker belum berjalan. Buka Docker Desktop dan tunggu sampai Engine running." }
docker --version

Langkah "2. Bersihkan kontainer lama"
foreach ($nama in @("cloud-test-nginx", "web-iaas-node", "production-api-container")) {
    $ada = docker ps -aq --filter "name=^/$nama$"
    if ($ada) { docker rm -f $nama | Out-Null; Write-Host "Dihapus: $nama" }
}
$pakai8080 = docker ps --filter "publish=8080" --format "{{.Names}}" | Where-Object { $_ -ne "jenkins-server" }
if ($pakai8080) { Gagal "Port 8080 masih dipakai kontainer: $($pakai8080 -join ', '). Hapus dengan: docker rm -f NAMA_KONTAINER, lalu jalankan skrip ini lagi." }
$pakai5000 = docker ps --filter "publish=5000" --format "{{.Names}}"
if ($pakai5000) { Gagal "Port 5000 masih dipakai kontainer: $($pakai5000 -join ', '). Hapus dengan: docker rm -f NAMA_KONTAINER, lalu jalankan skrip ini lagi." }
Write-Host "Port 8080 dan 5000 bebas."

Langkah "3. Build image Jenkins kustom (bisa beberapa menit)"
docker build -t jenkins-cicd:lab .\jenkins
if ($LASTEXITCODE -ne 0) { Gagal "Build image Jenkins gagal. Lihat pesan error di atas." }

Langkah "4. Network dan volume"
docker network inspect jenkins-net 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    docker network create jenkins-net | Out-Null
    Write-Host "Network jenkins-net dibuat."
} else {
    Write-Host "Network jenkins-net sudah ada."
}
docker volume create jenkins-data | Out-Null
docker volume create production-api-data | Out-Null
Write-Host "Volume jenkins-data dan production-api-data siap."

Langkah "5. Jalankan Jenkins"
$sudah = docker ps -aq --filter "name=^/jenkins-server$"
if ($sudah) {
    Write-Host "Kontainer jenkins-server lama dibuat ulang (data Jenkins tetap aman di volume jenkins-data)."
    docker rm -f jenkins-server | Out-Null
}
docker run -d --name jenkins-server --network jenkins-net -p 8080:8080 -p 50000:50000 -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --user root --restart unless-stopped jenkins-cicd:lab | Out-Null
if ($LASTEXITCODE -ne 0) { Gagal "Jenkins gagal dijalankan. Lihat pesan error di atas." }
Write-Host "jenkins-server berjalan."

Langkah "6. Verifikasi Docker CLI dan Python di dalam Jenkins (Screenshot 3.1)"
Write-Host "PS> docker exec jenkins-server docker version" -ForegroundColor DarkGray
docker exec jenkins-server docker version
if ($LASTEXITCODE -ne 0) { Gagal "Jenkins tidak bisa mengakses Docker." }
Write-Host ""
Write-Host "PS> docker exec jenkins-server python3 --version" -ForegroundColor DarkGray
docker exec jenkins-server python3 --version
if ($LASTEXITCODE -ne 0) { Gagal "Python 3 tidak ditemukan di Jenkins." }

Langkah "7. Menunggu Jenkins siap"
$pw = $null
for ($i = 1; $i -le 40; $i++) {
    $pw = docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
    if ($LASTEXITCODE -eq 0 -and $pw) { break }
    Write-Host "  menunggu... ($i/40)"
    Start-Sleep -Seconds 3
}
Write-Host ""
if ($pw) {
    Write-Host "Password awal Jenkins: $pw" -ForegroundColor Yellow
    Write-Host "Salin password ini ke halaman Jenkins. JANGAN sertakan di screenshot laporan."
} else {
    Write-Host "Password awal tidak ditemukan. Jika Jenkins sudah pernah Anda setup, login dengan akun admin yang dulu dibuat." -ForegroundColor Yellow
}
Start-Process "http://localhost:8080"
Write-Host ""
Write-Host "SELESAI. Lanjutkan Tahap 5.4 di browser yang baru terbuka." -ForegroundColor Green

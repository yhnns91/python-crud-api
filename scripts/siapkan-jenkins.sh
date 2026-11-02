#!/usr/bin/env bash
# Menyiapkan Jenkins untuk praktikum CI/CD (Tahap 0.3 dan 5.1 sampai 5.4).
# Jalankan dari folder python-crud-api di Git Bash:
#   bash scripts/siapkan-jenkins.sh

# Mencegah Git Bash mengubah path Linux (/var/run/...) menjadi path Windows.
export MSYS_NO_PATHCONV=1

C='\033[1;36m'; R='\033[1;31m'; Y='\033[1;33m'; G='\033[1;32m'; D='\033[0;90m'; N='\033[0m'
langkah() { echo; echo -e "${C}=== $1 ===${N}"; }
gagal()   { echo; echo -e "${R}GAGAL: $1${N}"; exit 1; }
perintah() { echo -e "${D}\$ $1${N}"; }

[ -f jenkins/Dockerfile ] || gagal "Jalankan skrip ini dari folder python-crud-api (folder yang berisi Jenkinsfile)."

langkah "1. Cek Docker"
docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || gagal "Docker belum berjalan. Buka Docker Desktop dan tunggu sampai Engine running."
docker --version

langkah "2. Bersihkan kontainer lama"
for nama in cloud-test-nginx web-iaas-node production-api-container; do
    if [ -n "$(docker ps -aq --filter "name=^/${nama}\$")" ]; then
        docker rm -f "$nama" >/dev/null && echo "Dihapus: $nama"
    fi
done
pakai8080=$(docker ps --filter publish=8080 --format '{{.Names}}' | grep -v '^jenkins-server$')
[ -z "$pakai8080" ] || gagal "Port 8080 masih dipakai kontainer: $pakai8080. Hentikan dengan: docker stop NAMA_KONTAINER, lalu jalankan skrip ini lagi."
pakai5000=$(docker ps --filter publish=5000 --format '{{.Names}}')
[ -z "$pakai5000" ] || gagal "Port 5000 masih dipakai kontainer: $pakai5000. Hentikan dengan: docker stop NAMA_KONTAINER, lalu jalankan skrip ini lagi."
echo "Port 8080 dan 5000 bebas."

langkah "3. Build image Jenkins kustom (bisa beberapa menit)"
docker build -t jenkins-cicd:lab ./jenkins || gagal "Build image Jenkins gagal. Lihat pesan error di atas."

langkah "4. Network dan volume"
if docker network inspect jenkins-net >/dev/null 2>&1; then
    echo "Network jenkins-net sudah ada."
else
    docker network create jenkins-net >/dev/null && echo "Network jenkins-net dibuat."
fi
docker volume create jenkins-data >/dev/null
docker volume create production-api-data >/dev/null
echo "Volume jenkins-data dan production-api-data siap."

langkah "5. Jalankan Jenkins"
if [ -n "$(docker ps -aq --filter 'name=^/jenkins-server$')" ]; then
    echo "Kontainer jenkins-server lama dibuat ulang (data Jenkins tetap aman di volume jenkins-data)."
    docker rm -f jenkins-server >/dev/null
fi
docker run -d --name jenkins-server --network jenkins-net \
    -p 8080:8080 -p 50000:50000 \
    -v jenkins-data:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --user root --restart unless-stopped \
    jenkins-cicd:lab >/dev/null || gagal "Jenkins gagal dijalankan. Lihat pesan error di atas."
echo "jenkins-server berjalan."

langkah "6. Verifikasi Docker CLI dan Python di dalam Jenkins (Screenshot 3.1)"
perintah "docker exec jenkins-server docker version"
docker exec jenkins-server docker version || gagal "Jenkins tidak bisa mengakses Docker."
echo
perintah "docker exec jenkins-server python3 --version"
docker exec jenkins-server python3 --version || gagal "Python 3 tidak ditemukan di Jenkins."

langkah "7. Menunggu Jenkins siap"
pw=""
for i in $(seq 1 40); do
    pw=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
    [ -n "$pw" ] && break
    echo "  menunggu... ($i/40)"
    sleep 3
done
echo
if [ -n "$pw" ]; then
    echo -e "${Y}Password awal Jenkins: $pw${N}"
    echo "Salin password ini ke halaman Jenkins. JANGAN sertakan di screenshot laporan."
else
    echo -e "${Y}Password awal tidak ditemukan. Jika Jenkins sudah pernah Anda setup, login dengan akun admin yang dulu dibuat.${N}"
fi
explorer.exe "http://localhost:8080" >/dev/null 2>&1 || true
echo
echo -e "${G}SELESAI. Buka http://localhost:8080 dan lanjutkan Tahap 5.4.${N}"

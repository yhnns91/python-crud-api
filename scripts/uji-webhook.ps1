# Tahap 10.4 dan 11: membuat commit kecil lalu push ke GitHub untuk memicu webhook.
#   powershell -ExecutionPolicy Bypass -File .\scripts\uji-webhook.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\uji-webhook.ps1 -Pesan "test: webhook saat ngrok mati"
param([string]$Pesan = "test: trigger GitHub webhook")

$waktu = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content README.md "Webhook test $waktu"
Write-Host "PS> git add README.md; git commit -m `"$Pesan`"; git push origin main" -ForegroundColor DarkGray
git add README.md
git commit -m "$Pesan"
git push origin main
Write-Host ""
Write-Host "Push selesai pukul $waktu. Buka Jenkins: build baru harus muncul otomatis tanpa Build Now." -ForegroundColor Green

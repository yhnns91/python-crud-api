FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY app.py .
EXPOSE 5000

# Tugas D: Docker HEALTHCHECK.
# Image python:3.11-slim tidak punya curl, jadi pengecekan memakai Python (urllib).
# urlopen() melempar error jika server tidak merespons / status bukan 2xx -> exit 1 (unhealthy).
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health', timeout=2)" || exit 1

CMD ["python", "app.py"]

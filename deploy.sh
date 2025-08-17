#!/usr/bin/env bash
set -euo pipefail

# ==== Настройки ====
REPO_URL="${REPO_URL:-https://github.com/n0rthf1ght3r/shvirtd-example-python.git}"
APP_DIR="/opt/shvirtd-example-python"

echo "[i] Installing Docker if needed..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER" || true
  echo "[i] Re-login may be required for docker group to take effect."
fi

echo "[i] Installing docker compose plugin if needed..."
if ! docker compose version >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y docker-compose-plugin
fi

echo "[i] Cloning repo to $APP_DIR..."
sudo rm -rf "$APP_DIR"
sudo git clone --depth=1 "$REPO_URL" "$APP_DIR"
sudo chown -R "$USER":"$USER" "$APP_DIR"
cd "$APP_DIR"

echo "[i] Writing .env with your production values..."
cat > ./.env <<'EOF'
MYSQL_ROOT_PASSWORD="YtReWq4321"
MYSQL_DATABASE="virtd"
MYSQL_USER="app"
MYSQL_PASSWORD="QwErTy1234"
EOF

echo "[i] Bringing up the stack..."
docker compose up -d --build

echo "[i] Waiting a little for MySQL healthcheck..."
sleep 10
docker ps
echo "[i] DB logs (tail):"
docker logs db --tail=60 || true

echo "[i] Quick HTTP check via proxy (8090):"
IP=$(curl -s ifconfig.me || echo "YOUR_VM_IP")
echo "Try:  curl -L http://$IP:8090"

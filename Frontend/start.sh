#!/usr/bin/env bash
set -Eeuo pipefail

# Update config.js with backend URL from environment (skip if read-only mount)
if [ -n "${API_BASE_URL:-}" ] && [ -w /home/chrome/extension/config.js ]; then
  sed -i "s|http://backend:8000|$API_BASE_URL|g" /home/chrome/extension/config.js || true
  sed -i "s|http://localhost:8000|$API_BASE_URL|g" /home/chrome/extension/config.js || true
fi

# Prepare a secure copy of the extension (Chrome may refuse world-writable mounts)
rm -rf /opt/extension && mkdir -p /opt/extension
cp -r /home/chrome/extension/. /opt/extension/ || true
find /opt/extension -type d -exec chmod 755 {} \; || true
find /opt/extension -type f -exec chmod 644 {} \; || true

# Start VNC server
vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes None &
sleep 3

# Start noVNC web server
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 &
sleep 2

# Start Openbox window manager
DISPLAY=:1 openbox &
sleep 2

# Create Chrome profile directory
mkdir -p /home/chrome/.config/google-chrome/Default

# Launch Chrome FIRST TIME to initialize profile (without extension)
echo "Initializing Chrome profile..."
DISPLAY=:1 timeout 15 google-chrome \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --start-maximized \
  --no-first-run \
  --no-default-browser-check \
  --user-data-dir=/home/chrome/.config/google-chrome \
  about:blank || true

# Wait for Chrome processes to fully stop
echo "Waiting for Chrome to fully initialize..."
sleep 3
pkill -9 chrome || true
sleep 2
# Clear Chrome profile locks if any persisted
rm -f /home/chrome/.config/google-chrome/Singleton* || true
rm -f /home/chrome/.config/google-chrome/Default/LOCK || true

# Enable Developer Mode after profile exists to avoid clobbering Preferences
if [ -f /home/chrome/.config/google-chrome/Default/Preferences ]; then
  tmpfile=$(mktemp)
  jq '.extensions.ui.developer_mode = true' \
    /home/chrome/.config/google-chrome/Default/Preferences \
    > "$tmpfile" 2>/dev/null && mv "$tmpfile" /home/chrome/.config/google-chrome/Default/Preferences || true
fi

# Launch Chrome with extension and persistent profile
echo "Starting Chrome with extension..."
DISPLAY=:1 google-chrome \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --start-maximized \
  --no-first-run \
  --no-default-browser-check \
  --user-data-dir=/home/chrome/.config/google-chrome \
  --remote-debugging-port=9222 \
  --remote-debugging-address=0.0.0.0 \
  --load-extension=/opt/extension \
  --enable-logging=stderr \
  --v=1 \
  chrome://extensions/ https://www.facebook.com &

# Keep container running
tail -f /dev/null

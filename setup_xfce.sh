#!/bin/bash
set -e

# Detect the actual user who invoked sudo (fallback to current user if run directly)
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(eval echo "~$TARGET_USER")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$TARGET_USER" = "root" ]; then
    echo "Error: Please run this script as a regular user with sudo (e.g., sudo ./setup_xfce.sh), not directly as root."
    exit 1
fi

echo "[1/5] Installing XFCE4 Minimal, File Manager (Thunar) and Archive tools..."
export DEBIAN_FRONTEND=noninteractive
apt update

apt install -y --no-install-recommends \
    xfce4 xfce4-terminal thunar thunar-archive-plugin engrampa \
    mousepad software-properties-common gpg-agent

echo "[2/5] Installing Firefox (.deb from official Mozilla PPA)..."
add-apt-repository -y ppa:mozillateam/ppa
cat << 'EOF' > /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF
apt update && apt install -y firefox

echo "[3/5] Deploying system wallpapers..."
mkdir -p /usr/share/backgrounds/xfce
if [ -d "$SCRIPT_DIR/wallpapers" ]; then
    cp -f "$SCRIPT_DIR/wallpapers/"* /usr/share/backgrounds/xfce/
    chmod 644 /usr/share/backgrounds/xfce/*
fi

echo "[4/5] Applying XFCE4 configuration for user: $TARGET_USER..."
if [ -d "$SCRIPT_DIR/config/xfce4" ]; then
    mkdir -p "$TARGET_HOME/.config"
    rm -rf "$TARGET_HOME/.config/xfce4"
    cp -r "$SCRIPT_DIR/config/xfce4" "$TARGET_HOME/.config/"
    
    # Replace any hardcoded user paths inside XML configs with the target user's home directory
    find "$TARGET_HOME/.config/xfce4" -type f -name "*.xml" -exec sed -i "s|/home/[^/]*/|$TARGET_HOME/|g" {} +
    
    # Fix ownership so the user can modify settings inside the GUI session
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config"
fi

echo "[5/5] Configuring /etc/xrdp/startwm.sh for clean single-click logout..."
if [ -f /etc/xrdp/startwm.sh ]; then
    if ! grep -q "exec dbus-run-session -- startxfce4" /etc/xrdp/startwm.sh; then
        sed -i 's/^wm_start/# wm_start/' /etc/xrdp/startwm.sh
        sed -i '/^# wm_start/i exec dbus-run-session -- startxfce4\n' /etc/xrdp/startwm.sh
    fi
fi

echo "=== SUCCESS! XFCE4 Minimal & custom configs applied for $TARGET_USER ==="

#!/bin/bash
set -e

# Detect the actual non-root user who invoked sudo
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(eval echo "~$TARGET_USER")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$TARGET_USER" = "root" ]; then
    echo "Error: Please run this script as a regular user with sudo (e.g., sudo ./setup_xfce.sh), not directly as root."
    exit 1
fi

echo "[1/5] Installing XFCE4, Xorg, LightDM, XKB plugin and dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt update

apt install -y --no-install-recommends \
    xfce4 xfce4-terminal xfce4-xkb-plugin xorg lightdm lightdm-gtk-greeter dbus-x11 \
    software-properties-common gpg-agent

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
else
    echo "WARNING: $SCRIPT_DIR/wallpapers not found! Skipping wallpapers."
fi

echo "[4/5] Applying XFCE4 configuration, shortcuts and keyboard autostart for $TARGET_USER..."
# Stop running XFCE daemons for the target user so cached settings do not overwrite copied files
pkill -9 -u "$TARGET_USER" xfconfd 2>/dev/null || true
pkill -9 -u "$TARGET_USER" xfce4-panel 2>/dev/null || true

if [ -d "$SCRIPT_DIR/config/xfce4" ]; then
    mkdir -p "$TARGET_HOME/.config"
    rm -rf "$TARGET_HOME/.config/xfce4"
    cp -r "$SCRIPT_DIR/config/xfce4" "$TARGET_HOME/.config/"
    
    # Replace any hardcoded user paths inside XML configs with the target user's home directory
    find "$TARGET_HOME/.config/xfce4" -type f -name "*.xml" -exec sed -i "s|/home/[^/]*/|$TARGET_HOME/|g" {} +
    
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config"
    echo "XFCE4 configuration successfully applied."
else
    echo "WARNING: $SCRIPT_DIR/config/xfce4 not found! Skipping config copy."
fi

# Deploy desktop shortcuts (e.g., Firefox)
if [ -d "$SCRIPT_DIR/desktop_icons" ]; then
    mkdir -p "$TARGET_HOME/Desktop"
    cp -f "$SCRIPT_DIR/desktop_icons/"*.desktop "$TARGET_HOME/Desktop/" 2>/dev/null || true
    chmod +x "$TARGET_HOME/Desktop/"*.desktop 2>/dev/null || true
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/Desktop"
fi

# Configure keyboard layout autostart (us,ru with Ctrl+Shift toggle) after xrdp session initialization
mkdir -p "$TARGET_HOME/.config/autostart"
cat << 'EOF' > "$TARGET_HOME/.config/autostart/xkb-layout.desktop"
[Desktop Entry]
Type=Application
Name=Set Keyboard Layout
Exec=sh -c "sleep 2 && setxkbmap -layout us,ru -option grp:ctrl_shift_toggle"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/autostart"

echo "[5/5] Configuring /etc/xrdp/startwm.sh for clean single-click logout..."
if [ -f /etc/xrdp/startwm.sh ]; then
    if ! grep -q "exec dbus-run-session -- startxfce4" /etc/xrdp/startwm.sh; then
        sed -i 's/^wm_start/# wm_start/' /etc/xrdp/startwm.sh
        sed -i '/^# wm_start/i exec dbus-run-session -- startxfce4\n' /etc/xrdp/startwm.sh
    fi
fi

echo "=== SUCCESS! XFCE4 & custom configs applied for $TARGET_USER ==="


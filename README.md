Automated post-installation script to deploy a lightweight **XFCE4 Minimal** desktop environment, **Firefox (.deb)**, custom wallpapers, and pre-configured clean panel/desktop layouts on **Ubuntu 24.04 LTS**.

Designed to work seamlessly alongside [xrdp-modern-lvgl-installer](https://github.com) for **any non-root user**.

## What This Script Does

1. **Installs Lightweight XFCE4 Stack:** Installs core XFCE4, terminal, Thunar file manager, archive manager (Engrampa), and Mousepad text editor without bloated recommendations.
2. **Installs Firefox (.deb):** Adds the official Mozilla Team PPA with priority pinning to bypass Snap and install native `.deb` Firefox.
3. **Deploys Wallpapers:** Copies images from `wallpapers/` into `/usr/share/backgrounds/xfce/` so they are globally accessible.
4. **Applies Pre-configured Desktop Layout:** Copies `config/xfce4` into the invoking user's `~/.config/xfce4`, automatically adapts any hardcoded home paths, and sets proper ownership.
5. **Configures `xrdp` Session Startup:** Updates `/etc/xrdp/startwm.sh` with `exec dbus-run-session -- startxfce4` so logging out of XFCE closes the RDP session cleanly on the first click.

## Usage

Log in as your regular (non-root) user with `sudo` privileges, clone the repository, and run the script:

```bash
git clone https://github.com/sanotes-ru/xfce4-custom-desktop-setup
cd xfce4-custom-desktop-setup
chmod +x setup_xfce.sh
sudo ./setup_xfce.sh
```

*(Note: Run this script **before** starting your first RDP session so XFCE doesn't overwrite the applied configuration files).*

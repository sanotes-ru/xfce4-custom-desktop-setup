Automated post-installation script to deploy a lightweight **XFCE4 Minimal** desktop environment, **Xorg**, **LightDM**, **Firefox (.deb)**, custom wallpapers, desktop shortcuts, and pre-configured panel/keyboard layouts on **Ubuntu 20.xx LTS**.

Designed to work seamlessly alongside [xrdp-modern-lvgl-installer](https://github.com) for **any non-root user**.

## Repository Structure

```text
xfce4-custom-desktop-setup/
├── config/
│   └── xfce4/           # Pre-configured XFCE4 XML settings (panels, desktop, theme)
├── wallpapers/          # Custom background images deployed to /usr/share/backgrounds/xfce/
├── desktop_icons/       # .desktop application shortcuts copied to ~/Desktop
├── setup_xfce.sh        # Main deployment script
└── README.md
```

## What This Script Does

1. **Installs Minimal Desktop Stack:** Installs `xfce4`, `xfce4-terminal`, `xfce4-xkb-plugin`, `xorg`, `lightdm`, `lightdm-gtk-greeter`, and `dbus-x11` without bloated recommendations.
2. **Installs Firefox (.deb):** Adds the official Mozilla Team PPA with priority pinning (`1001`) to bypass Snap and install native `.deb` Firefox.
3. **Deploys System Wallpapers:** Copies images from `wallpapers/` into `/usr/share/backgrounds/xfce/` so they are globally accessible across all users.
4. **Applies Pre-configured Desktop & Shortcuts:**
   - Safely stops running `xfconfd` and `xfce4-panel` processes for the target user so cached settings do not overwrite new files.
   - Copies `config/xfce4` into `~/.config/xfce4`.
   - Copies `.desktop` files from `desktop_icons/` into `~/Desktop` and marks them executable (`chmod +x`).
5. **Configures RDP-Safe Keyboard Switching (`us,ru`):** Creates `~/.config/autostart/xkb-layout.desktop` to apply `us,ru` layouts with `Ctrl + Shift` toggling after a 2-second delay (preventing `xrdp` from overriding XKB settings during initial connection).
6. **Configures `xrdp` Session Startup:** Updates `/etc/xrdp/startwm.sh` with `exec dbus-run-session -- startxfce4` so logging out of XFCE closes the RDP session cleanly on the first click.

## Usage

Log in as your regular (non-root) user with `sudo` privileges, clone the repository, and run the script:

```bash
git clone https://github.com/sanotes-ru/xfce4-custom-desktop-setup
cd xfce4-custom-desktop-setup
chmod +x setup_xfce.sh
sudo ./setup_xfce.sh
```

*(Note: Run this script **before** starting your first session so XFCE doesn't overwrite the applied configuration files).*

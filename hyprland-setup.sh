#!/bin/bash
# hyprland-setup.sh
# Complete Hyprland environment setup for Arch Linux
# Includes Waybar, Wofi, PipeWire/PulseAudio, Bluetooth, LXTASK, smart volume & brightness, XF86 keys, Thunar with archive support...

set -e

echo "[1/15] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/15] Installing essential packages..."
sudo pacman -S --noconfirm hyprland swaybg hyprlock hypridle waybar wofi grim slurp wl-clipboard xorg-xwayland \
    xorg-xhost alacritty librewolf brave pamac neovim localsend \
    network-manager-applet nm-connection-editor xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-utils \
    ttf-font-awesome-4 noto-fonts papirus-icon-theme jq gnome-themes-extra adwaita-qt5-git adwaita-qt6-git qt5ct qt6ct \
    nwg-look nwg-clipman ristretto thunar thunar-archive-plugin thunar-volman gvfs engrampa zip unzip p7zip unrar \
    playerctl swaync swayosd libnotify inotify-tools brightnessctl polkit-gnome power-profiles-daemon \
    lxtask mate-calc gsimplecal gammastep cliphist gnome-font-viewer mousepad autotiling || true

yay -S --noconfirm masterpdfeditor-free wayscriber-bin || true

mkdir -p ~/Desktop
mkdir -p ~/Code
mkdir -p ~/Documents
mkdir -p ~/Downloads
mkdir -p ~/Pictures
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Videos

mkdir -p ~/.config

# Create custom zsh syntax highlighing theme file
touch ~/.config/zsh_syntax_theme

# -----------------------
# Adding file templates
# -----------------------
echo 'XDG_TEMPLATES_DIR="$HOME/.local/share/templates"' >> ~/.config/user-dirs.dirs

cat > /tmp/templates.sh <<'EOF'
#!/bin/bash

TEMPLATES="$HOME/.local/share/templates"
mkdir -p "$TEMPLATES"
chmod +w "$TEMPLATES"

WORKDIR=$(mktemp -d)

# TXT Template
cat > "$TEMPLATES/Document.txt" <<'EOT'
This is a blank text document.
EOT

# Build proper DOCX structure

mkdir -p "$WORKDIR/docx_template/_rels"
mkdir -p "$WORKDIR/docx_template/word/_rels"

# Required root relationship file
cat > "$WORKDIR/docx_template/_rels/.rels" <<'EOT'
<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
                Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
                Target="word/document.xml"/>
</Relationships>
EOT

# Required word/document.xml
mkdir -p "$WORKDIR/docx_template/word"
cat > "$WORKDIR/docx_template/word/document.xml" <<'EOT'
<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t></w:t></w:r></w:p>
  </w:body>
</w:document>
EOT

# Required word/document.xml.rels
cat > "$WORKDIR/docx_template/word/_rels/document.xml.rels" <<'EOT'
<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"></Relationships>
EOT

# Required content types
cat > "$WORKDIR/docx_template/[Content_Types].xml" <<'EOT'
<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/word/document.xml" 
            ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>
EOT

# Zip into DOCX
(
  cd "$WORKDIR/docx_template"
  zip -qr "$TEMPLATES/Document.docx" .
)

# Code templates
cat > "$TEMPLATES/Script.py" <<'EOT'
print("Hello, World!")
EOT

cat > "$TEMPLATES/Script.js" <<'EOT'
console.log("Hello, World!");
EOT

chmod -w "$TEMPLATES"
rm -rf "$WORKDIR"
EOF

bash /tmp/templates.sh
rm -f /tmp/templates.sh

# ----------------------------------------
# Adding accounts for Librewolf browser
# ----------------------------------------
# 1. Define paths
FP_PATH="/usr/lib/librewolf"
CFG_PATH="$FP_PATH/librewolf.cfg"
PREF_PATH="$FP_PATH/defaults/pref"
ACFILE="$PREF_PATH/autoconfig.js"

# 2. Ensure directory exists
sudo mkdir -p "$PREF_PATH"

# 3. Create main autoconfig file
sudo tee "$CFG_PATH" > /dev/null <<'EOF'
// LibreWolf AutoConfig
// This file is loaded at Librewolf startup. Do not leave blank lines above this header.

// ----------------- Fingerprinting protection (granular control) ----------------
defaultPref("privacy.resistFingerprinting", false);
defaultPref("privacy.fingerprintingProtection", true);
defaultPref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");   
lockPref("dom.gamepad.enabled", false);
lockPref("dom.netinfo.enabled", false);
// lockPref("dom.enable_performance", false);
lockPref("dom.telephony.enabled", false);
lockPref("dom.vibrator.enabled", false);
lockPref("device.sensors.enabled", false);
lockPref("dom.battery.enabled", false);
lockPref("network.http.referer.XOriginPolicy", 2);

// ----------------- Profiles + Accounts -----------------
defaultPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
defaultPref("browser.profiles.enabled", true);
defaultPref("identity.fxaccounts.enabled", true);  // enables Firefox Sync UI

// ----------------- Set tracker blocking to strict ---------------
pref("browser.contentblocking.category", "strict");
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.pbmode.enabled", true);
pref("privacy.trackingprotection.socialtracking.enabled", true);
pref("privacy.trackingprotection.fingerprinting.enabled", true);
pref("privacy.trackingprotection.cryptomining.enabled", true);

// ----------------- Cookie / Storage ---------------------
defaultPref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
defaultPref("privacy.sanitize.sanitizeOnShutdown", false);
defaultPref("privacy.clearOnShutdown.cookies", false);
defaultPref("privacy.clearOnShutdown.offlineApps", false);
defaultPref("privacy.clearOnShutdown.cache", false);

// ----------------- DNS ----------------------------
pref("network.trr.uri", "https://cloudflare-dns.com/dns-query");
pref("network.trr.mode", 2);
defaultPref("network.trr.bootstrapAddress", "1.1.1.1");

// ----------------- WebRTC Leak Protection ---------------
defaultPref("media.peerconnection.enabled", true);
pref("media.peerconnection.ice.obfuscate_host_addresses", true);

// ---------------- Enable WebGL (to not break 3D sites, but still togglable) ------------------
defaultPref("webgl.disabled", false);

// ----------------- Password Saving ----------------------
pref("signon.rememberSignons", false);

// ----------------- Disable saving search and form history ---------------
defaultPref("browser.formfill.enable", false);

// ----------------- Disable Payments + Autofill ---------------
pref("dom.payments.enabled", false);
pref("extensions.formautofill.creditCards.enabled", false);
pref("extensions.formautofill.addresses.enabled", false);

// ---------------- Enable HTTPS-only mode in private windows only ----------------
pref("dom.security.https_only_mode", false);
pref("dom.security.https_only_mode_pbm", true);
EOF

echo "[+] Created $CFG_PATH"

# 4. Create autoconfig loader
sudo tee "$ACFILE" > /dev/null <<'EOF'
pref("general.config.filename", "librewolf.cfg");
pref("general.config.obscure_value", 0);
EOF

echo "[+] Created $ACFILE"

echo "✅ LibreWolf autoconfig successfully installed"

# -----------------------
# Audio system selection
# -----------------------
echo "[3/15] Selecting audio system..."
echo "Select audio system (default PipeWire):"
echo "1) PipeWire"
echo "2) PulseAudio"
read -p "Enter choice [1-2]: " audio_choice
audio_choice=${audio_choice:-1}
 
if [ "$audio_choice" -eq 2 ]; then
    echo "[4/15] Installing PulseAudio..."
    sudo pacman -S --noconfirm pulseaudio pavucontrol
    echo "PulseAudio selected."
else
    echo "[4/15] Installing PipeWire (default)..."
    sudo pacman -S --noconfirm pipewire pipewire-pulse wireplumber pavucontrol
    echo "PipeWire selected."
fi

echo "[5/15] Enabling audio and desktop portal services..."
if [ "$audio_choice" -eq 2 ]; then
    systemctl --user enable pulseaudio xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
else
    systemctl --user enable pipewire pipewire-pulse wireplumber xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
fi
systemctl --user daemon-reload

echo "[6/15] Setting default applications..."

# ensure dirs exist
mkdir -p ~/.local/share/applications

# install xdg-utils if missing (non-blocking)
if ! command -v xdg-mime >/dev/null 2>&1; then
  echo "Installing xdg-utils..."
  sudo pacman -S --noconfirm xdg-utils || true
fi

# Create fallback .desktop files (only if missing)

# AUR Package Search (through Librewolf)
if [[ ! -f ~/.local/share/applications/librewolf-AUR_Package_Search.desktop ]]; then
cat > ~/.local/share/applications/librewolf-AUR_Package_Search.desktop <<'EOF'
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=AUR Package Search
Exec=/usr/bin/librewolf "https://aur.archlinux.org/packages?O=0&K="
Icon=applications-internet
URL=https://aur.archlinux.org/packages?O=0&K=
Comment=Open https://aur.archlinux.org/packages?O=0&K= in a new tab in Librewolf.
EOF
fi

# Chaotic AUR Package Search (through Librewolf)
if [[ ! -f ~/.local/share/applications/librewolf-Chaotic_AUR_Package_Search.desktop ]]; then
cat > ~/.local/share/applications/librewolf-Chaotic_AUR_Package_Search.desktop <<'EOF'
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=Chaotic AUR Package Search
Exec=/usr/bin/librewolf "https://aur.chaotic.cx/packages"
Icon=applications-internet
URL=https://aur.chaotic.cx/packages
Comment=Open https://aur.chaotic.cx/packages in a new tab in Librewolf.
EOF
fi

# Neovim
if [[ ! -f ~/.local/share/applications/nvim.desktop ]]; then
cat > ~/.local/share/applications/nvim.desktop <<'EOF'
[Desktop Entry]
Name=Neovim
GenericName=Text Editor
TryExec=nvim
Exec=alacritty -e nvim %F
Terminal=false
Type=Application
Keywords=Text;editor;
Icon=nvim
Categories=Utility;TextEditor;
StartupNotify=false
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
EOF
fi

# Update desktop database (user-level) if tool exists; don't fail script on error
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database ~/.local/share/applications || true
fi

# Build (or replace) user-level mimeapps list (freedesktop standard)
MIMEFILE="$HOME/.config/mimeapps.list"
cat > "$MIMEFILE" <<'EOF'
[Default Applications]
text/plain=org.xfce.mousepad.desktop
text/x-markdown=nvim.desktop
application/x-shellscript=nvim.desktop
text/html=brave-browser.desktop
x-scheme-handler/http=brave-browser.desktop
x-scheme-handler/https=brave-browser.desktop
application/pdf=masterpdfeditor4.desktop
image/png=org.xfce.ristretto.desktop
image/jpeg=org.xfce.ristretto.desktop
image/jpg=org.xfce.ristretto.desktop
image/gif=org.xfce.ristretto.desktop
image/bmp=org.xfce.ristretto.desktop
image/webp=org.xfce.ristretto.desktop
image/svg+xml=brave-browser.desktop
x-scheme-handler/terminal=Alacritty.desktop
application/xhtml+xml=brave-browser.desktop
text/xml=brave-browser.desktop
application/rss+xml=brave-browser.desktop
application/atom+xml=brave-browser.desktop
text/x-c=nvim.desktop
text/x-c++=nvim.desktop
text/x-python=nvim.desktop
text/x-java=nvim.desktop
text/x-shellscript=nvim.desktop
text/x-javascript=nvim.desktop
text/css=nvim.desktop
text/x-typescript=nvim.desktop
text/markdown=nvim.desktop
EOF

# Also set via xdg-mime as a fallback (make browser open files for viewing and neovim for editing)

# Images → ristretto
xdg-mime default org.xfce.ristretto.desktop image/png image/jpeg image/jpg image/bmp image/gif || true

# Default file manager -> Thunar
xdg-mime default thunar.desktop inode/directory

# Browser stuff → Brave
xdg-mime default brave-browser.desktop text/html || true
xdg-mime default brave-browser.desktop application/xhtml+xml || true
xdg-mime default brave-browser.desktop image/svg+xml || true
xdg-mime default brave-browser.desktop text/xml || true
xdg-mime default brave-browser.desktop application/rss+xml || true
xdg-mime default brave-browser.desktop application/atom+xml || true

# Pdf editor and viewer
xdg-mime default masterpdfeditor4.desktop application/pdf || true

# Terminal handler
xdg-mime default Alacritty.desktop x-scheme-handler/terminal || true

# Code → Neovim
xdg-mime default nvim.desktop text/x-c || true
xdg-mime default nvim.desktop text/x-c++ || true
xdg-mime default nvim.desktop text/x-python || true
xdg-mime default nvim.desktop text/x-java || true
xdg-mime default nvim.desktop text/x-shellscript || true
xdg-mime default nvim.desktop text/x-javascript || true
xdg-mime default nvim.desktop text/css || true
xdg-mime default nvim.desktop text/x-typescript || true
xdg-mime default nvim.desktop text/markdown || true

# Plain text → Mousepad
xdg-mime default org.xfce.mousepad.desktop text/plain || true

# Export env vars once (avoid duplicates)
grep -qxF 'export BROWSER=brave' ~/.profile 2>/dev/null || echo 'export BROWSER=brave' >> ~/.profile
grep -qxF 'export TERMINAL=alacritty' ~/.profile 2>/dev/null || echo 'export TERMINAL=alacritty' >> ~/.profile
grep -qxF 'export DOCUMENT_VIEWER=masterpdfeditor4' ~/.profile 2>/dev/null || echo 'export DOCUMENT_VIEWER=masterpdfeditor4' >> ~/.profile

echo "Default applications set (user mimeapps.list written to $MIMEFILE)."

# -----------------------
# Bluetooth installation
# -----------------------
echo "[7/15] Installing Bluetooth stack and GUI..."
sudo pacman -S --noconfirm bluez bluez-utils blueberry
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# ------------------------------------------------
# Enable NetworkManager and power-profiles-daemon
# ------------------------------------------------
sudo systemctl enable NetworkManager
sudo systemctl enable power-profiles-daemon

# -----------------------
# Waybar configuration
# -----------------------
echo "[8/15] Configuring Waybar..."

mkdir -p ~/.config/waybar

cat > ~/.config/waybar/config <<'EOF'
{
  "layer": "top",
  "position": "top",

  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["battery", "bluetooth", "backlight", "pulseaudio", "hyprland/language", "tray", "custom/notifications"],

  "clock": {
    "format": "{:%a %b %d  %H:%M}",
    "tooltip-format": "Click to toggle calendar",
    "on-click": "gsimplecal --toggle"
  },

  "battery": {
    "format": "<span font='Font Awesome 6 Free'>{icon}</span> {capacity}% - {time}",
    "format-icons": ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"],
    "format-charging": "<span font='Font Awesome 6 Free'>\uf0e7</span> <span font='Font Awesome 6 Free 11'>{icon}</span> {capacity}% - {time}",
    "format-full": "<span font='Font Awesome 6 Free'>\uf0e7</span> <span font='Font Awesome 6 Free 11'>{icon}</span> Charged",
    "format-unknown": "<span font='Font Awesome 6 Free'>\uf390</span>",
    "interval": 12,
    "states": {
      "warning": 20,
      "critical": 10
    },
    "on-click": "~/.local/bin/power-profiles.sh"
  },

  "pulseaudio": {
    "format": "<span font='Font Awesome 6 Free 11'>\uf026</span> {volume}%",
    "on-click": "pavucontrol",
    "capped-values": true
  },

  "backlight": {
  "format": "<span font='Font Awesome 6 Free'>\uf185</span> {percent}%",
  "on-scroll-up": "brightnessctl set +5%",
  "on-scroll-down": "brightnessctl set 5%-",
  "tooltip-format": "Brightness"
  }, 

  "bluetooth": {
    "format-on": " {num_connections}",
    "format-off": " off",
    "tooltip-format": "Bluetooth: {status}\n{device_alias} ({device_address})",
    "on-click": "blueberry"
  },

  "hyprland/language": {
    "format": "{short} {variant}"
  },

  "custom/notifications": {
    "format": "<span font='Font Awesome 6 Free'>\uf0f3</span>",
    "on-click": "swaync-client -t",
    "tooltip-format": "Notifications"
  },

  "tray": {
    "icon-size": 15,
    "spacing": 10
  },

  "hyprland/workspaces": {
  "format": "{name} {icon}",
  "on-scroll-up": "hyprctl dispatch workspace e-1",
  "on-scroll-down": "hyprctl dispatch workspace e+1",
  "format-icons": {
    "active": "\u25cf",
    "default": "\u25CB"
  }
  }
}
EOF

if [[ ! -f ~/.config/waybar/style.css ]]; then
cat > ~/.config/waybar/style.css <<'EOF'
/* ---------- THEME VARIABLES ---------- */
@define-color module_text #ffffff;

/* ---------- GLOBAL ---------- */
* {
  font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", "Noto Sans";
  font-size: 14px;
  color: @module_text;
}

/* Fully transparent top bar */
window#waybar {
  background-color: rgba(0, 0, 0, 0.0);
}

/* Workspaces block */
#workspaces {
  padding: 0px 5px;
}

/* Clock styling */
#clock {
  font-size: 16px;
  font-weight: bold;
}

/* Module container backgrounds */
.modules-left,
.modules-center,
.modules-right {
  background-color: rgba(0, 0, 0, 0.6);
  border-radius: 10px;
  padding: 0 5px;
  margin: 0 5px;
}

/* Padding for modules */
#battery,
#pulseaudio,
#network,
#bluetooth,
#backlight,
#language,
#tray,
#custom-notifications,
#workspaces {
  padding: 0 7px;
}
EOF
fi

# -----------------------
# Configure Hyprland
# -----------------------
echo "[9/15] Configuring Hyprland..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/swaync
mkdir -p ~/.config/swayosd
mkdir -p ~/.config/xfce4
mkdir -p ~/.config/xdg-desktop-portal

# Start swayosd libinput backend
sudo systemctl enable swayosd-libinput-backend

cat > ~/.config/hypr/hyprlock.conf <<'EOF'
# Dark Mode / Eye-Friendly hyprlock.conf

general {
    disable_loading_bar = true
    grace = 700
    hide_cursor = false
}

# The Background
background {
    monitor = 
    path = $(cat $HOME/.cache/lastwallpaper)
    blur_passes = 3    
}

# Centered, Dark Input Field
input-field {
    monitor = 
    size = 300, 50 
    position = 0, 0 
    halign = center
    valign = center
    
    outline_thickness = 2 # Thin border
    
    # Dark/Muted Colors for minimal intensity
    inner_color = rgb(151515DD) # Very dark gray, slightly transparent
    outer_color = rgb(333333FF) # Darker gray border
    
    font_color = rgb(AAAAAA) # Muted white text
    placeholder_text = <span foreground="##555555">Enter Password...</span> # Very dark gray placeholder
    
    # Error/Success colors should still be visible but not neon
    fail_color = rgb(A00000) # Muted red for failure
    check_color = rgb(006000) # Dark green for success
    
    dots_size = 0
}

# Muted Time Label
label {
    monitor = 
    text = cmd[update:1000] echo "<b>$(date +'%H:%M')</b>"
    font_size = 20
    
    # Muted white text color
    color = rgb(999999DD) 
    
    position = 0, -150 
    halign = center
    valign = center
}
EOF

# Setting default terminal to Alacritty for Thunar
cat > ~/.config/xfce4/helpers.rc <<'EOF'
TerminalEmulator=alacritty
EOF

cat > ~/.config/hypr/hypridle.conf <<'EOF'
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 300 # in 5 minutes (300 seconds) of idle time, lock screen
    on-timeout = hyprlock
}

listener {
    timeout = 420 # in 7 minutes (420 seconds) of idle time, turn screen off
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

listener {
    timeout = 600 # in 10 minutes (600 seconds) of idle time, suspend to save power
    on-timeout = systemctl suspend
}
EOF

# --------------------------------------
# Configure xdg-desktop-portal-hyprland
# --------------------------------------
cat > ~/.config/hypr/xdph.conf <<'EOF'
screencopy {
allow_token_by_default = true
}
EOF

# --------------------------------------------------
# Configuring desktop portals (for proper dark mode)
# --------------------------------------------------
cat > ~/.config/xdg-desktop-portal/hyprland-portals.conf <<'EOF'
[preferred]
default=hyprland;gtk
EOF

# -----------------------
# Configuring SwayNC
# -----------------------
cat > ~/.config/swaync/config.json <<'EOF'
{
  "positionX": "right",
  "positionY": "top",
  "layer": "overlay",
  
  "osd-positionX": "center",
  "osd-positionY": "center",
  "osd-window-width": 300,
  "osd-timeout": 1500,
  "osd-output": "auto",
  
  "control-center-layer": "overlay",
  "control-center-positionX": "right",
  "control-center-positionY": "top",
  "notification-window-width": 400,
  "control-center-width": 500,
  "notification-visibility": {
    "low": {
      "timeout": 5
    },
    "normal": {
      "timeout": 5
    },
    "critical": {
      "timeout": 7
    }
  },
  "widgets": [
    "title",
    "dnd",
    "notifications",
    "mpris",
    "volume",
    "brightness"
  ],
  "widget-config": {
    "title": {
      "text": "Control Center",
      "clear-all-button": true
    },
    "dnd": {
      "text": "Do Not Disturb"
    },
    "volume": {
      "label": " Volume",
      "max-volume": 140, 
      "min-volume": 0,
      "volume-command-up": "sh -c 'wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+'",
      "volume-command-down": "sh -c 'wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-'",
      "volume-command-mute": "sh -c 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'"
    },
    "brightness": {
      "label": "󰃟 Brightness",
      "min-brightness": 5,
      "brightness-command-up": "sh -c 'brightnessctl set +5%'",
      "brightness-command-down": "sh -c 'brightnessctl set 5%-' "
    },
    "mpris": {
      "image-size": 96,
      "image-radius": 12
    }
  }
}
EOF

cat > ~/.config/swaync/style.css <<'EOF'
/* Note: Removed Gtk theme import. If you want it, use a valid path on your system,
   like: @import '/usr/share/themes/Adwaita-dark/gtk-3.0/gtk.css'; 
   But the error suggests this path is invalid, so let's use the defaults. */

/* ======================================= */
/* OSD Window (Volume/Brightness Indicator) */
/* ======================================= */
.osd-window {
    background-color: rgba(30, 30, 45, 0.9);
    border-radius: 12px;
    border: 1px solid rgba(100, 100, 120, 0.5);
    padding: 20px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.6);
}

/* The OSD label (e.g., "🔊 Volume") */
.osd-window .label {
    font-size: 1.2rem;
    font-weight: bold;
    color: #cdd6f4;
    margin-bottom: 10px;
}

/* The OSD progress bar */
.osd-window progress {
    background-color: #444;
    border: none;
    border-radius: 8px;
}

.osd-window progress trough {
    background-color: #333;
    border-radius: 8px;
    /* Use min-height to set the size of the bar */
    min-height: 20px;
}

.osd-window progress progress {
    background-color: #89b4fa;
    /* Accent Color (Blue) */
    border-radius: 8px;
}


/* ======================================= */
/* Standard Notification Styling (Optional) */
/* ======================================= */

.notification-row {
    outline: none;
    margin: 12px;
}

.notification {
    background-color: rgba(30, 30, 45, 0.9);
    border-radius: 12px;
    border: 1px solid rgba(100, 100, 120, 0.5);
    padding: 10px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
}

.title {
    font-size: 1.2rem;
    font-weight: bold;
    color: #cdd6f4;
}

.body {
    font-size: 1rem;
    color: #cdd6f4;
}
EOF

# --------------------------
# COnfiguring SwayOSD for colored volume and brightness indicator
# --------------------------
cat > ~/.config/swayosd/style.css <<'EOF'
window#osd {
  background: rgba(0, 0, 0, 0.9);
}

window#osd progress {
  background: #3a5f9e;
}

window#osd image {
  color: #3a5f9e;
}
EOF

# ---------------------
# Adding pacman hooks
# ---------------------
echo "Adding pacman hooks to prevent sleep on updates"
sudo mkdir -p /etc/pacman.d/hooks

sudo tee /etc/pacman.d/hooks/00-inhibit-sleep.hook > /dev/null <<'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Inhibiting sleep during package operations...
When = PreTransaction
Exec = /bin/bash -c "/usr/bin/systemd-inhibit --what=sleep:idle --who=pacman --why='Pacman is running' --mode=block /usr/bin/sleep infinity >/dev/null 2>&1 &"
EOF

# Write 99-release-inhibit.hook
sudo tee /etc/pacman.d/hooks/99-release-inhibit.hook > /dev/null <<'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Releasing sleep inhibit lock...
When = PostTransaction
Exec = /bin/bash -c "/usr/bin/pkill -f 'systemd-inhibit.*Pacman' || true"
EOF

# -----------------------
# Configure Alacritty (transparent background)
# -----------------------
echo "[10/15] Configuring Alacritty"
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.toml <<'EOF'
[window]
opacity = 0.5

# To set a custom font:
# [font]
# size = 11.2
#
# [font.normal]
# family = "FontName"
# style = "Regular"
#
# [font.bold]
# style = "Bold"
#
# [font.italic]
# style = "Italic"
#
# [font.bold_italic]
# style = "Bold Italic"
#
# [font.offset]
# x = 0
# y = 1
EOF

# ------------------
# Screen Locking
# ------------------
mkdir -p ~/.local/bin
cat > ~/.local/bin/lock.sh <<'EOF'
#!/bin/bash

# -----------------------------
# Configuration
# -----------------------------
LOCK_TIMEOUT=300         # 5 minutes (300 seconds) → lock screen
DPMS_TIMEOUT=600         # 10 minutes (600 seconds) → turn off display
CONFIG_DIR="$HOME/.config/hypr"
CONFIG_PATH="$CONFIG_DIR/hypridle.conf"

# --- Compositor Detection & Command Setup ---
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    COMPOSITOR="hyprland"
    IDLE_MANAGER="hypridle"
    
    echo "Detected Compositor: Hyprland. Using hypridle and generating config."

elif [ -n "$SWAYSOCK" ]; then
    COMPOSITOR="sway"
    IDLE_MANAGER="swayidle"
    
    LOCKER_CMD='swaylock -f \
      -c 000000 \
      --indicator \
      --indicator-radius 120 \
      --indicator-thickness 15 \
      --inside-color 1e1e2eff \
      --ring-color 4c7899ff \
      --key-hl-color 990000ff \
      --bs-hl-color ff0000ff \
      --text-color ffffffff \
      --line-color 00000000 \
      --separator-color 00000000 \
      --inside-ver-color 285577ff \
      --ring-ver-color 4c7899ff \
      --inside-wrong-color ff0000ff \
      --ring-wrong-color ff0000ff \
      --fade-in 0.3'
      
    DPMS_OFF_CMD='swaymsg "output * dpms off"'
    DPMS_ON_CMD='swaymsg "output * dpms on"'
    
    # swayidle command line arguments
    IDLE_ARGS="-w \
        timeout $LOCK_TIMEOUT \"$LOCKER_CMD\" \
        timeout $DPMS_TIMEOUT \"$DPMS_OFF_CMD\" \
        resume \"$DPMS_ON_CMD\" \
        before-sleep \"$LOCKER_CMD\""
        
    echo "Detected Compositor: Sway. Using swayidle."
    
else
    echo "Error: Neither Sway nor Hyprland detected. Exiting."
    exit 1
fi
# -----------------------------

# Kill any existing manager to avoid conflicts
killall $IDLE_MANAGER 2>/dev/null || true

# --- Execute Idle Manager ---
if [ "$COMPOSITOR" = "hyprland" ]; then
    # 3. Execute hypridle, which will automatically find the config file
    $IDLE_MANAGER &

elif [ "$COMPOSITOR" = "sway" ]; then
    # swayidle uses command line arguments, using 'eval' for safe execution of the string
    eval $IDLE_MANAGER $IDLE_ARGS &
fi

echo "$IDLE_MANAGER started in the background."
EOF
chmod +x ~/.local/bin/lock.sh

# ------------------
# Cheat sheet for keybindings
# ------------------
cat > ~/.local/bin/toggle-cheatsheet.sh <<'EOF'
#!/bin/bash

CHEATSHEET_TITLE="Hyprland Cheatsheet"
CHEATSHEET_FILE="$HOME/.config/hypr/cheatsheet.txt"
TERMINAL="alacritty"

# Search by title (more reliable)
CON_ID=$(hyprctl -j clients | jq -r '.[] | select(.title == "'"$CHEATSHEET_TITLE"'") | .address')

if [ -n "$CON_ID" ]; then
    hyprctl dispatch closewindow address:$CON_ID
else
    "$TERMINAL" --class "cheatsheet" --title "$CHEATSHEET_TITLE" -e less "$CHEATSHEET_FILE" &
fi
EOF
chmod +x ~/.local/bin/toggle-cheatsheet.sh

# ------------------
# Wofi toggle
# ------------------
cat > ~/.local/bin/toggle-wofi.sh <<'EOF'
#!/bin/bash

# Check if Wofi is already running
if pgrep -x "wofi" > /dev/null; then
    # If running, kill it
    pkill wofi
else
    # If not running, launch it
    wofi --show drun --insensitive --allow-images
fi
EOF
chmod +x ~/.local/bin/toggle-wofi.sh

# ------------------
# Wofi toggle
# ------------------
cat > ~/.local/bin/toggle-animations.sh <<'EOF'
#!/bin/bash

STATE_FILE="$HOME/.cache/hypr_animations_state"

# Initialize if missing (default: animations on)
if [[ ! -f "$STATE_FILE" ]]; then
    echo "1" > "$STATE_FILE"
fi

state=$(cat "$STATE_FILE")

# Toggle animations
if [[ $state -eq 1 ]]; then
    hyprctl keyword animations:enabled 0
    echo "0" > "$STATE_FILE"
    hyprctl notify -1 1000 "rgb(e06c75)" "Animations off"
else
    hyprctl keyword animations:enabled 1
    echo "1" > "$STATE_FILE"
    hyprctl notify -1 1000 "rgb(98c379)" "Animations on"
fi
EOF
chmod +x ~/.local/bin/toggle-animations.sh

# ------------------
# Dynamic workspace functionality (if workspace doesn't exist, create it)
# ------------------
cat > ~/.local/bin/dynamic-workspaces.sh <<'EOF'
#!/bin/bash

direction=$1

if [ "$direction" = "next" ]; then
    hyprctl dispatch workspace +1
elif [ "$direction" = "prev" ]; then
    hyprctl dispatch workspace -1
else
    exit 1
fi
EOF
chmod +x ~/.local/bin/dynamic-workspaces.sh

# ------------------
# Wallpaper Settings
# ------------------
cat > ~/.local/bin/set-wallpaper.sh <<'EOF'
#!/bin/bash

# --- Configuration Variables ---
DIR="$HOME/Pictures/Wallpapers"
LAST="$HOME/.cache/lastwallpaper"

COMPOSITOR="hyprland"
CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"
RELOAD_CMD="hyprctl reload"

# Build list for wofi: simply list filenames
CHOICE=$(find "$DIR" -maxdepth 1 -type f | while read -r img; do 
    basename "$img"
done | wofi --show dmenu --prompt "Wallpaper:")

# If user picked something, set & save it
if [ -n "$CHOICE" ]; then
    FILE="$DIR/$CHOICE"
    echo "$FILE" > "$LAST"
    
    # --- IMMEDIATE WALLPAPER SETTING ---
    pkill -f swaybg
    swaybg -i "$FILE" -m fill &
    
    # --- CONFIGURATION UPDATE ---

    BG_CONFIG_LINE="exec = swaybg -i $FILE -m fill"
    
    # 1. Escape the file path for use in sed
    ESCAPED_FILE=$(echo "$FILE" | sed 's/[\/&]/\\&/g')
    ESCAPED_NEW_LINE="exec = swaybg -i ${ESCAPED_FILE} -m fill"
    
    # 2. Check and replace (or append) the swaybg exec command
    if grep -q "^exec = swaybg " "$CONFIG_FILE"; then
        # Replace existing line using 'c\' (change line)
        sed -i "/^exec = swaybg /c\\${ESCAPED_NEW_LINE}" "$CONFIG_FILE"
    else
        # Append to the config file
        echo "${BG_CONFIG_LINE}" >> "$CONFIG_FILE"
    fi

    # --- RELOAD COMPOSITOR ---
    $RELOAD_CMD
fi
EOF
chmod +x ~/.local/bin/set-wallpaper.sh

# ------------------
# Display Settings
# ------------------
cat > ~/.local/bin/display-settings.sh <<'EOF'
#!/bin/bash

# If wofi is already opened, close it
if pgrep -x wofi >/dev/null; then
    pkill -x wofi
    exit 0
fi

COMPOSITOR="hyprland"
CONFIG="$HOME/.config/hypr/hyprland.conf"

# STEP 1: Get monitor outputs.
outputs=$(hyprctl -j monitors | jq -r '.[].name')

[ -z "$outputs" ] && echo "ERROR: No monitor outputs detected." && exit 1

chosen_output=$(echo "$outputs" | wofi --dmenu --prompt "Select monitor:")
[ -z "$chosen_output" ] && exit 0

# STEP 2: Get modes. Uses .availableModes[] field.
modes=$(hyprctl -j monitors | jq -r --arg out "$chosen_output" '.[] | select(.name == $out) | .availableModes[]')

[ -z "$modes" ] && echo "ERROR: No modes found for $chosen_output." && exit 1

# STEP 3: Second wofi prompt
chosen_mode=$(echo "$modes" | wofi --dmenu --prompt "Select resolution:")
[ -z "$chosen_mode" ] && exit 0

# Apply the setting: monitor name, mode, position (auto), scale (1)
hyprctl keyword monitor "$chosen_output,$chosen_mode,auto,1"

confirm=$(echo -e "yes\nno" | wofi --dmenu --prompt "Save to hyprland config?")
if [ "$confirm" == "yes" ]; then
    sed -i "/^monitor=$chosen_output/d" "$CONFIG"
    echo "monitor=$chosen_output, $chosen_mode, 0x0, 1" >> "$CONFIG"
fi
EOF
chmod +x ~/.local/bin/display-settings.sh

# ------------------
# Screenshots
# ------------------
cat > ~/.local/bin/screenshot.sh <<'EOF'
#!/bin/bash

# If wofi is already opened, close it
if pgrep -x wofi >/dev/null; then
    pkill -x wofi
    exit 0
fi

# Directory for screenshots
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Default filename with timestamp
DEFAULT_FILE="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"

# Ask user: full screen or select region
MODE=$(printf "Full Screen\nSelect Area" | wofi --dmenu --prompt "Capture mode:")
[ -z "$MODE" ] && exit 0

# Determine geometry argument
if [ "$MODE" = "Select Area" ]; then
    GEOM=$(slurp)
    [ -z "$GEOM" ] && exit 0
    GEOM="-g \"$GEOM\""  # quote the geometry
else
    GEOM=""  # Full screen
fi

# Save screenshot to a temporary file
if [ -n "$GEOM" ]; then
    eval grim $GEOM /tmp/screenshot.png
else
    grim /tmp/screenshot.png
fi

# Ask user for filename
FILENAME=$(echo "$DEFAULT_FILE" | wofi --dmenu --prompt "Save screenshot as:")
[ -z "$FILENAME" ] && exit 0

# Append .png if missing
case "$FILENAME" in
    *.png) ;;
    *) FILENAME="$FILENAME.png" ;;
esac

# Move the screenshot to the final location
mv /tmp/screenshot.png "$DIR/$FILENAME"

# Notify user
notify-send "Screenshot saved" "$DIR/$FILENAME"
EOF
chmod +x ~/.local/bin/screenshot.sh

# ------------------------
# Changing power profiles
# ------------------------
cat > ~/.local/bin/power-profiles.sh <<'EOF'
#!/bin/bash

# Get current profile
CURRENT=$(powerprofilesctl get | tr -d ' ')

# Define options
OPTIONS="performance\nbalanced\npower-saver"

# Show current profile and let user pick
CHOICE=$(echo -e "current: $CURRENT\n$OPTIONS" | grep -v "^$CURRENT$" | wofi --dmenu --prompt="Select Power Profile")

# Apply if a valid choice is made and different from current
if [ -n "$CHOICE" ] && [ "$CHOICE" != "current: $CURRENT" ]; then
    powerprofilesctl set "$CHOICE" && notify-send "Power Profile" "Set to $CHOICE"
fi
EOF
chmod +x ~/.local/bin/power-profiles.sh

# ------------------------
# Theme Switcher
# ------------------------
cat > ~/.local/bin/theme-switcher.sh <<'EOF'
#!/bin/bash

WAYBAR_CSS="$HOME/.config/waybar/style.css"
WOFI_CSS="$HOME/.config/wofi/style.css"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
SWAYOSD_CSS="$HOME/.config/swayosd/style.css"

ZSH_SYNTAX_FILE="$HOME/.config/zsh_syntax_theme"

THEME_FILE="$HOME/.config/current_theme"

CHOICE=$(printf "Default\nTelva\nMatrix" | wofi --dmenu --prompt "Select Theme")

# Read currently applied theme
CURRENT_THEME=""
[ -f "$THEME_FILE" ] && CURRENT_THEME=$(cat "$THEME_FILE")

# Exit if same theme chosen
if [ "$CHOICE" = "$CURRENT_THEME" ]; then
    exit 0
fi

# --- Waybar ---
set_waybar_color() {
    local color="$1"
    sed -i 's/@define-color module_text .*/@define-color module_text '"$color"';/' "$WAYBAR_CSS"
}

# --- Wofi ---
set_wofi_highlight() {
    local color="$1"
    sed -i '/#entry:selected {/,/}/c\
        #entry:selected {\
    background-color: '"$color"';\
        color: #ffffff;\
    }' "$WOFI_CSS"
}

# --- Hyprland ---
set_hypr_border() {
    local c1="$1"

    sed -i 's/^\([[:space:]]*\)col.active_border.*/\1col.active_border = rgba('"$c1"')/' "$HYPR_CONF"
    hyprctl reload >/dev/null 2>&1
}

# --- SwayOSD ---
set_swayosd_color() {
    local color="$1"

    sed -i '/window#osd progress/ {n; s/background:.*;/background: '"$color"';/}' "$SWAYOSD_CSS"
    sed -i '/window#osd image/ {n; s/color:.*;/color: '"$color"';/}' "$SWAYOSD_CSS"

    # Restart swayosd-server to apply changes
    pkill -x swayosd-server >/dev/null 2>&1
    swayosd-server -s "$SWAYOSD_CSS" >/dev/null 2>&1 &
}

# --- Dircolors (for ls and similar commands output color) --
set_dircolors() {
    local color_code="$1"
    local dircolors_file="$HOME/.dircolors"
    
    # Generate default if missing
    [ ! -f "$dircolors_file" ] && dircolors -p > "$dircolors_file"

    # Replace the DIR line safely
    sed -i "s/^DIR[[:space:]].*/DIR ${color_code}/" "$dircolors_file"

    # Reapply LS_COLORS
    eval "$(dircolors "$dircolors_file")"
}

# --- zsh-syntax-highlighting ---
set_zsh_syntax_color_file() {
    local color="$1" 
    cat > "$ZSH_SYNTAX_FILE" <<EOT
    ZSH_HIGHLIGHT_STYLES[command]='fg=$color'
	ZSH_HIGHLIGHT_STYLES[precommand]='fg=$color'
	ZSH_HIGHLIGHT_STYLES[builtin]='fg=$color'
    ZSH_HIGHLIGHT_STYLES[path]='fg=$color,underline'
	ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=$color'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=$color'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=$color'
EOT
}

# --- Theme selection ---
case "$CHOICE" in
    "Telva")
        set_waybar_color "#c78cff"
        set_wofi_highlight "#702963"
        set_hypr_border "a080ccee"
        set_swayosd_color "#702963"
        set_zsh_syntax_color_file "13"
        set_dircolors "01;38;2;180;120;220"
        echo "Telva" > "$THEME_FILE"
        pkill -SIGUSR2 waybar
        ;;
    "Matrix")
        set_waybar_color "#7FFFD4"
        set_wofi_highlight "darkgreen"
        set_hypr_border "5fd8b3ee"
        set_swayosd_color "darkgreen"
        set_zsh_syntax_color_file "120"
        set_dircolors "01;38;2;100;200;160"
        echo "Matrix" > "$THEME_FILE"
        pkill -SIGUSR2 waybar
        ;;
    "Default")
        set_waybar_color "#ffffff"
        set_wofi_highlight "#3a5f9e"
        set_hypr_border "80b8f0ee"
        set_swayosd_color "#4169E1"
        set_zsh_syntax_color_file "12"
        set_dircolors "01;34"
        echo "Default" > "$THEME_FILE"
        pkill -SIGUSR2 waybar
        ;;
esac
EOF
chmod +x ~/.local/bin/theme-switcher.sh

# ------------------------------------------
# Managing Peripherals (mouse and touchpad)
# ------------------------------------------
cat > ~/.local/bin/input-config.sh <<'EOF'
#!/bin/bash

# If wofi is already opened, close it
if pgrep -x wofi >/dev/null; then
    pkill -x wofi
    exit 0
fi

HYPR_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"

[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ] && notify-send "Error: Hyprland not detected." && exit 1
[ ! -f "$HYPR_CONFIG" ] && notify-send "Error: Config not found at $HYPR_CONFIG" && exit 1

SENSITIVITY=$(grep -E "^\s*sensitivity\s*=" "$HYPR_CONFIG" | tail -n 1 | sed -E 's/.*=\s*([-0-9.]+).*/\1/')
[ -z "$SENSITIVITY" ] && SENSITIVITY="0.5"

SCROLL_FACTOR=$(grep -E "^\s*scroll_factor\s*=" "$HYPR_CONFIG" | tail -n 1 | sed -E 's/.*=\s*([0-9.]+).*/\1/')
[ -z "$SCROLL_FACTOR" ] && SCROLL_FACTOR="0.8"

PROFILE=$(grep -E "^\s*accel_profile\s*=" "$HYPR_CONFIG" | tail -n 1 | sed -E 's/.*=\s*([a-zA-Z]+).*/\1/')
[ -z "$PROFILE" ] && PROFILE="adaptive"

OPTION=$(printf "Set Mouse Sensitivity\nSet Scroll Speed\nToggle Mouse Acceleration (flat / adaptive)" | wofi --dmenu --prompt "Option:")
[ -z "$OPTION" ] && exit 0

# Function to validate numeric input
validate_number() {
    local input="$1"
    local min="$2"
    local max="$3"
    # Check if input is a valid number (optional - sign, at least one digit, optional decimal part)
    if ! [[ "$input" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        return 1
    fi
    # Check bounds using bc for floating point comparison
    if (( $(echo "$input < $min" | bc -l) )) || (( $(echo "$input > $max" | bc -l) )); then
        return 1
    fi
    return 0
}

case "$OPTION" in
    "Set Mouse Sensitivity")
        while true; do
            SENS_VAL=$(echo "$SENSITIVITY" | wofi --dmenu --prompt "Set sensitivity (-1.0 to 1.0):")
            [ -z "$SENS_VAL" ] && exit 0
            if validate_number "$SENS_VAL" -1.0 1.0; then
                break
            else
                notify-send "Enter a number between -1.0 and 1.0"
            fi
        done
        hyprctl keyword input:sensitivity "$SENS_VAL"
        sed -i -E "s/^(\\s*sensitivity\\s*=\\s*)[-0-9.]+(\\s*#.*)?$/\\1$SENS_VAL\\2/" "$HYPR_CONFIG"
        notify-send "Mouse sensitivity set to $SENS_VAL"
        ;;
    "Set Scroll Speed")
        while true; do
            SCROLL_VAL=$(echo "$SCROLL_FACTOR" | wofi --dmenu --prompt "Set scroll speed (0.1 to 4.0):")
            [ -z "$SCROLL_VAL" ] && exit 0
            if validate_number "$SCROLL_VAL" 0.1 4.0; then
                break
            else
                notify-send "Enter a number between 0.1 and 4.0"
            fi
        done
        hyprctl keyword input:scroll_factor "$SCROLL_VAL"
        hyprctl keyword input:touchpad:scroll_factor "$SCROLL_VAL"
        sed -i -E "s/^(\\s*scroll_factor\\s*=\\s*)[0-9.]+(\\s*#.*)?$/\\1$SCROLL_VAL\\2/" "$HYPR_CONFIG"
        sed -i -E "/touchpad\\s*{/,/}/ s/^(\\s*scroll_factor\\s*=\\s*)[0-9.]+(\\s*#.*)?$/\\1$SCROLL_VAL\\2/" "$HYPR_CONFIG"
        notify-send "Scroll speed set to $SCROLL_VAL"
        ;;
    "Toggle Mouse Acceleration (flat / adaptive)")
        NEW_PROFILE="flat"
        [ "$PROFILE" = "flat" ] && NEW_PROFILE="adaptive"
        hyprctl keyword input:accel_profile "$NEW_PROFILE"
        hyprctl keyword input:touchpad:accel_profile "$NEW_PROFILE"
        sed -i -E "s/^(\\s*accel_profile\\s*=\\s*)[a-zA-Z]+(\\s*#.*)?$/\\1$NEW_PROFILE\\2/" "$HYPR_CONFIG"
        notify-send "Mouse acceleration set to $NEW_PROFILE"
        ;;
esac
EOF
chmod +x ~/.local/bin/input-config.sh

cat > ~/.config/hypr/hyprland.conf <<'EOF'
# ================================
# MOD KEYS
# ================================

# SUPER = SuperKey (Windows Key / Meta Key), ALT = Alt Key
$mod = ALT


# VFR = Variable Frame Rate - Reduce frame rendering when screen is static (set it to true to reduce power consumption)
# Set it to false if you experience lag when resizing windows or if monitor flickers due to rapid refresh rate changes
misc:vfr = true

# Set this to true if you want to enable blur effect and false if you want to disable it (looks cool, but draws more power)
decoration:blur:enabled = false

# Set this to true if you want to enable shadows and false if you want to disable it (looks cool, but draws more power)
decoration:shadow:enabled = false


# ================================
# STARTUP
# ================================
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
exec-once = xhost +SI:localuser:root
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = nm-applet --indicator
exec-once = sleep 2 && waybar
exec-once = swaync
exec-once = swayosd-server -s ~/.config/swayosd/style.css
exec-once = gammastep -O 1510
exec-once = ~/.local/bin/lock.sh
exec-once = /usr/bin/gnome-keyring-daemon --start --components=secrets
exec-once = gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
exec-once = gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
exec-once = gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

# ================================
# ENVIRONMENT VARIABLES
# ================================
env = QT_STYLE_OVERRIDE, Adwaita-dark

# ================================
# APPEARANCE
# ================================
general {
    gaps_in = 4
    gaps_out = 2
    border_size = 2
    layout = dwindle
    # Active window border color
    col.active_border = rgba(80b8f0ee)
}

decoration {
    # Rounded corners
    rounding = 5
}

misc {
    disable_hyprland_logo = true
}

ecosystem {
    no_update_news = true
}

# ================================
# INPUTS
# ================================
input {
    # ba - bosnian layout, en - english layout
    kb_layout = ba,us
    # Alt + Shift - alt_shift_toggle, Superkey + Space - win_space_toggle
    kb_options = grp:win_space_toggle
    # Mouse Acceleration
	accel_profile = adaptive
    # Mouse Sensitivity
	sensitivity = 0.5
    # Scroll Speed
	scroll_factor = 0.8
    touchpad {
        natural_scroll = true
        tap-to-click = true

	    scroll_factor = 0.8
    } 
}

# ================================
# APP LAUNCHERS
# ================================

# Draw on-screen (press ESC to close drawing mode)
bind = $mod, D, exec, wayscriber --active

# Edit this hyprland config (~/.config/hypr/hyprland.conf)
bind = $mod SHIFT CTRL, H, exec, alacritty -e nvim ~/.config/hypr/hyprland.conf

# Terminal (mod + enter)
bind = $mod, RETURN, exec, alacritty
# Brave Browser (mod + b)
bind = $mod, B, exec, brave
# File Manager (mod + e)
bind = $mod, E, exec, thunar
# Toggle Cheat Sheet (mod + shift + c)
bind = $mod SHIFT, C, exec, ~/.local/bin/toggle-cheatsheet.sh
# Take a screenshot (mod + shift + s)
bind = $mod SHIFT, S, exec, ~/.local/bin/screenshot.sh
# Settings for input devices like mouse and touchpad (mod + shift + i)
bind = $mod SHIFT, I, exec, ~/.local/bin/input-config.sh
# Settings for displays (mod + shift + d)
bind = $mod SHIFT, D, exec, ~/.local/bin/display-settings.sh
# Wallpaper picker (mod + shift + w) (Must have some images in /home/username/Pictures/Wallpapers to select them)
bind = $mod SHIFT, W, exec, ~/.local/bin/set-wallpaper.sh
# GTK GUI settings (mod + shift + t)
bind = $mod SHIFT, T, exec, nwg-look
# Theme switcher (mod + t)
bind = $mod, T, exec, ~/.local/bin/theme-switcher.sh
# Toggle application Launcher (mod + space)
bind = $mod, SPACE, exec, ~/.local/bin/toggle-wofi.sh
# Open power menu (mod + shift + q)
bind = $mod SHIFT, Q, exec, ~/.local/bin/power-menu.sh
# Lock he screen (mod + ctrl + shift + l)
bind = $mod CTRL SHIFT, L, exec, hyprlock
# Open task manager (mod + shift + esc)
bind = CTRL SHIFT, ESCAPE, exec, lxtask
# Open clipboard manager (mod + v)
bind = $mod, V, exec, nwg-clipman

# ================================
# WINDOW MANAGEMENT
# ================================
# Close Window
bind = $mod, Q, killactive
# Make window full-screen
bind = $mod, F, fullscreen
# Toggle window between floating and tiling mode
bind = $mod SHIFT, SPACE, togglefloating

# Move tiling windows around (with ModKey + Shift + H,J,K,L)
bind = $mod SHIFT, H, movewindow, l
bind = $mod SHIFT, J, movewindow, d
bind = $mod SHIFT, K, movewindow, u
bind = $mod SHIFT, L, movewindow, r   

# Move floating windows around (with ModKey + Shift + H,J,K,L)
bind = $mod SHIFT, H, moveactive, -100 0
bind = $mod SHIFT, L, moveactive, 100 0
bind = $mod SHIFT, K, moveactive, 0 -100
bind = $mod SHIFT, J, moveactive, 0 100

# Move focus between windows (with ModKey + H,J,K,L or ModKey + Arrow Keys)
bind = $mod, H, movefocus, l
bind = $mod, L, movefocus, r
bind = $mod, K, movefocus, u
bind = $mod, J, movefocus, d

bind = $mod, LEFT, movefocus, l
bind = $mod, RIGHT, movefocus, r
bind = $mod, UP, movefocus, u
bind = $mod, DOWN, movefocus, d

# mod + left mouse button drag to move windows around
bindm = $mod, mouse:272, movewindow
# mod + right mouse button drag to resize windows
bindm = $mod, mouse:273, resizewindow

# ====================================================================
# Touchpad gestures (4-finger swipe horizontally to switch workpaces)
# ====================================================================
gesture = 4, horizontal, workspace


# Zoom in and out with ModKey + Plus / ModKey + Minus
binde = $mod, minus, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 - 0.1}')
binde = $mod, plus, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.1}')   

binde = $mod, KP_Subtract, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 - 0.1}')
binde = $mod, KP_Add, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.1}')   

# ================================
# RESIZE MODE
# ================================
# Enter resize mode (close by pressing ESC or ENTER)
bind = $mod, R, submap, resize

submap = resize
binde = , L, resizeactive, 10 0
binde = , H, resizeactive, -10 0
binde = , K, resizeactive, 0 -10
binde = , J, resizeactive, 0 10
bind = , RETURN, submap, reset
bind = , ESCAPE, submap, reset
submap = reset

# ================================
# WORKSPACES
# ================================
# Switch Workspaces
bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5
bind = $mod, 6, workspace, 6
bind = $mod, 7, workspace, 7
bind = $mod, 8, workspace, 8
bind = $mod, 9, workspace, 9
bind = $mod, 0, workspace, 10

# Move window to workspace
bind = $mod SHIFT, 1, movetoworkspace, 1
bind = $mod SHIFT, 2, movetoworkspace, 2
bind = $mod SHIFT, 3, movetoworkspace, 3
bind = $mod SHIFT, 4, movetoworkspace, 4
bind = $mod SHIFT, 5, movetoworkspace, 5
bind = $mod SHIFT, 6, movetoworkspace, 6
bind = $mod SHIFT, 7, movetoworkspace, 7
bind = $mod SHIFT, 8, movetoworkspace, 8
bind = $mod SHIFT, 9, movetoworkspace, 9
bind = $mod SHIFT, 0, movetoworkspace, 10

# Super + Mouse scroll to switch workspaces dynamically
bind = $mod, mouse_up, exec, ~/.local/bin/dynamic-workspaces.sh next
bind = $mod, mouse_down, exec, ~/.local/bin/dynamic-workspaces.sh prev

# ================================
# SWAYNC (Notification Center)
# ================================
# Mod + N to toggle the notification/control center
bind = $mod, N, exec, swaync-client -t
# Mod + Shift + N to close all notifications
bind = $mod SHIFT, N, exec, swaync-client -C

# ================================
# VOLUME CONTROL
# ================================
# Raise volume by 5%, maximum volume is 155% (set to any value you want)
binde = , XF86AudioRaiseVolume, exec, swayosd-client --output-volume 5 --max-volume 155
# Lower volume by 5%, maximum volume is 155% (set to any value you want)
binde = , XF86AudioLowerVolume, exec, swayosd-client --output-volume -5 --max-volume 155
# Mute volume
bind = , XF86AudioMute, exec, swayosd-client --output-volume mute-toggle

# ===================
# ModKey + Shift + Right/Left - fallback volume control keys
# ===================
# Raise volume by 5%, maximum volume is 155% (set to any value you want)
binde = $mod SHIFT, RIGHT, exec, swayosd-client --output-volume 5 --max-volume 155
# Lower volume by 5%, maximum volume is 155% (set to any value you want)
binde = $mod SHIFT, LEFT, exec, swayosd-client --output-volume -5 --max-volume 155
# Mute volume
bind = $mod SHIFT, M, exec, swayosd-client --output-volume mute-toggle

# ================================
# BRIGHTNESS CONTROL
# ================================
# Raise brightness by 5%
binde = , XF86MonBrightnessUp, exec, swayosd-client --brightness +5
# Lower brightness by 5%
binde = , XF86MonBrightnessDown, exec, swayosd-client --brightness -5

# ===================
# ModKey + Shift + Up/Down - fallback brightness control keys
# ===================
# Raise brightness by 5%
bind = $mod SHIFT, UP, exec, swayosd-client --brightness +5
# Lower brightness by 5%
bind = $mod SHIFT, DOWN, exec, swayosd-client --brightness -5

# ================================
# Show Caps Lock
# ================================
# Capslock Indicator
bind = , Caps_Lock, exec, swayosd-client --caps-lock

# ==================================
# Check if animations are on or off
# ==================================
exec = bash -c '[ -f ~/.cache/hypr_animations_state ] || echo 1 > ~/.cache/hypr_animations_state; hyprctl keyword animations:enabled $(cat ~/.cache/hypr_animations_state)'
bind = $mod SHIFT, X, exec, ~/.local/bin/toggle-animations.sh

# ==================================
# Wallpaper and Display settings
# ==================================
EOF

cat > ~/.config/hypr/cheatsheet.txt <<'EOF'

                                   HYPRLAND WINDOW MANAGER KEYBINDINGS CHEATSHEET  
     (Quick reference for essential Hyprland controls — you can modify all bindings in ~/.config/hypr/hyprland.conf file.)  
             (Mod = your main modifier key — it is Alt by default, but you can change it in the config file.)

                    ================================================================================
                                              WINDOW MANAGEMENT & FOCUS
                    ================================================================================
                        Mod + Q ....................... Close focused window
                        Mod + F ....................... Toggle fullscreen
                        Mod + Shift + Space ........... Toggle floating / tiling mode
                        Mod + R ....................... Enter resize mode (Esc / Enter to exit)
                        Mod + H / J / K / L ........... Move focus left / down / up / right
                        Mod + Arrow Keys .............. Move focus left / right / up / down
                        Mod + Shift + H / J / K / L ... Move window left / down / up / right
                        Mod + Left Click Drag ......... Move window
                        Mod + Right Click Drag ........ Resize window

                    ================================================================================
                                                    WORKSPACES
                    ================================================================================
                        Mod + 1–0 ..................... Switch to workspace 1–10
                        Mod + Shift + 1–0 ............. Move window to workspace 1–10
                        Mod + Scroll Up/Down .......... Switch workspaces dynamically
                        4-finger swipe (touchpad) ..... Switch workspaces horizontally

                    ================================================================================
                                                  APP LAUNCHERS
                    ================================================================================
                        Mod + Return .................. Terminal (Alacritty)
                        Mod + Space ................... App launcher (Wofi)
                        Mod + E ....................... File manager (Thunar)
                        Mod + B ....................... Web browser (Brave)
                        Mod + V ....................... Clipboard manager (Clipman)
                        Ctrl + Shift + Escape ......... Task manager (Lxtask)

                    ================================================================================
                                                SYSTEM & UTILITIES
                    ================================================================================
                        Mod + Shift + Q ............... Power menu (Shutdown, Reboot, etc.)
                        Mod + Ctrl + Shift + L ........ Lock screen (Hyprlock)
                        Mod + Shift + S ............... Take screenshot
                        Mod + Shift + C ............... Toggle this cheatsheet
                        Mod + N ....................... Toggle notifications/control center
                        Mod + Shift + N ............... Dismiss all notifications

                    ================================================================================
                                              MEDIA & BRIGHTNESS
                    ================================================================================
                        Mod + Shift + Left / Right .... Adjust volume down / up
                        Mod + Shift + M ............... Toggle mute
                        Mod + Shift + Up / Down ....... Adjust brightness up / down
                        Caps Lock ..................... Show Caps Lock indicator

                    ================================================================================
                                            CONFIGURATION & APPEARANCE
                    ================================================================================
                        Mod + Shift + D ............... Display settings / monitor config
                        Mod + Shift + I ............... Input devices / peripherals config
                        Mod + Shift + Ctrl + H ........ Open hyprland configuration file
                        Mod + T ....................... Theme switcher
                        Mod + Shift + W ............... Wallpaper picker (from ~/Pictures/Wallpapers)
                        Mod + Shift + X ............... Toggle window animations

                    ================================================================================
                                                  MISCELLANEOUS
                    ================================================================================
                        Mod + D ....................... Draw on screen (wayscriber) — press Esc to exit
                        Super/Windows key + Space ................... Toggle keyboard layout (ba/us)
EOF

# -----------------------
# Wofi configuration
# -----------------------
echo "[11/15] Configuring Wofi..."

# Setting Papirus icon theme as default
mkdir -p ~/.config/gtk-3.0
if [[ ! -f ~/.config/gtk-3.0/settings.ini ]]; then
    # File does not exist → create it with header and key
    cat > ~/.config/gtk-3.0/settings.ini <<'EOF'
[Settings]
gtk-icon-theme-name=Papirus-Dark
gtk-application-prefer-dark-theme=1
EOF
else
    # File exists → ensure it has [Settings], then add key if missing
    if ! grep -q "^\[Settings\]" ~/.config/gtk-3.0/settings.ini; then
        sed -i '1i [Settings]' ~/.config/gtk-3.0/settings.ini
    fi

    grep -qxF "gtk-icon-theme-name=Papirus-Dark" ~/.config/gtk-3.0/settings.ini 2>/dev/null || \
    echo "gtk-icon-theme-name=Papirus-Dark" >> ~/.config/gtk-3.0/settings.ini
fi

mkdir -p ~/.config/wofi
# Main config (functional options)
cat > ~/.config/wofi/config <<'EOF'
[wofi]
show=drun
allow-images=true
icon-theme=Papirus-Dark
term=alacritty
EOF

# Style (GTK CSS selectors)
cat > ~/.config/wofi/style.css <<'EOF'
#window {
  border: 1px solid #1e1e2e;
  background-color: #1e1e2e;
  border-radius: 8px;
  font-family: "Noto Sans";
}

label {
  padding: 6px;
}

#icon {
  min-width: 25px;
  opacity: 0;
}

#input {
  border: none;
  margin: 6px;
  padding: 6px;
  background-color: #1e1e2e;
  color: #ffffff;
  font-size: 15px;
}

#entry {
  padding: 6px;
  background-color: #1e1e2e;
  color: #ffffff;
}

#entry:selected {
  background-color: #3a5f9e;
  color: #ffffff;
}

#text {
  color: #ffffff;
}
EOF

# -----------------------
# Power menu script
# -----------------------
echo "[12/15] Creating power menu script..."
cat > ~/.local/bin/power-menu.sh <<'EOF'
#!/bin/bash

# Detect compositor
if pidof sway >/dev/null; then
    compositor="sway"
elif pidof Hyprland >/dev/null; then
    compositor="hyprland"
else
    compositor="unknown"
fi

# Show menu
choice=$(printf "Power off\nReboot\nLogout" | wofi --show dmenu --prompt "Power Menu")

case "$choice" in
    "Power off")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Logout")
        if [ "$compositor" = "sway" ]; then
            swaymsg exit
        elif [ "$compositor" = "hyprland" ]; then
            hyprctl dispatch exit
        else
            notify-send "Unknown compositor" "Cannot logout"
            exit 1
        fi
        ;;
esac
EOF
chmod +x ~/.local/bin/power-menu.sh

# -----------------------
# Default brightness
# -----------------------
echo "[14/15] Setting default brightness to 15%..."
brightnessctl set 15%
sudo usermod -aG video $USER

echo "[15/15] Final touches and reminders..."
echo "✅ Setup complete!"
echo " - Task Manager: Ctrl+Shift+Esc (LXTASK)"
echo " - Network Manager: Waybar click → nm-connection-editor"
echo " - Bluetooth Manager: Waybar click → blueman-manager"
echo " - Wallpaper Selection: Super+Shift+W"
echo " - Volume Keys: XF86Audio keys + smart fallback Super+Shift+Right/Left/M (with OSD)"
echo " - Brightness Keys: XF86MonBrightness keys + smart fallback Super+Shift+Up/Down (with OSD)"
echo " - Media Keys: Play/Pause/Next/Prev supported"
echo " - Keyboard layout switching: Alt+Shift"

echo "Restart Hyprland to apply all changes."
echo "Done!"

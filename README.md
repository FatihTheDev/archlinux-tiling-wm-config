# Arch Linux Sway/Hyprland Config

A complete, minimal, and highly functional **Sway/Hyprland setup for Arch Linux**, including Waybar, Wofi, PipeWire, smart volume & brightness controls, lightweight GUI utilities, and default keybindings.

This setup is designed for **minimal Arch installations** and provides a user-friendly yet lightweight desktop experience.

---

## Features

- **Waybar** at the top with:
  - Centered large clock  
  - Battery percentage  
  - Volume control  
  - WiFi and network status  
  - Bluetooth status and device management  
  - System tray  

- **Wofi** as an app launcher on `Super + Space` keys
- **Power menu** with Poweroff, Reboot, Logout via `Super + Shift + Q`  
- **Browsers**:
  - Brave → `Super+B`  
  - LibreWolf 
- **Terminal** → `Super+Enter` (Alacritty)  
- **File manager** → `Super+E` (Thunar)
- **GTK App Theme Settings** → `Super+Shift+T`
- **Task Manager GUI** → `Ctrl+Shift+Esc` (LXTASK)  
- **Keyboard layouts**: Bosnian (`ba`) and English (`us`), switched with `Alt+Shift`  
- **Screenshot tool** → `Super+Shift+S`  
- **Volume controls**:
  - XF86 hardware keys supported  
  - Smart fallback keys if hardware keys fail: `Super+Shift+Right` (volume up), `Super+Shift+Left` (volume down), `Super+Shift+M` (mute)  
- **Brightness controls**:
  - XF86 hardware keys supported  
  - Smart fallback keys if hardware keys fail: `Super+Shift+Up` (increase), `Super+Shift+Down` (decrease)  
  - Default brightness set to **15%**  
- **Wallpaper Changer (need to have an image in ~/Pictures/Wallpapers)** → `Super+Shift+W`
- **Tabbed layout toggle (Hyprland doesn't support tabbed layout)** -> `Super+T`
- **Floating/Tilind layouts toggle** -> `Super+Shift+Space`
- **Lock screen** -> `Super+Ctrl+Shift+L`
- **Media keys**: Play/Pause, Next, Previous (via Playerctl)
- **Display CheatSheet of all keybindings** -> `Super+Shift+C`

---

## Keybindings Overview

| Action                      | Keybinding                  |
|------------------------------|-----------------------------|
| App launcher (Wofi)          | Super + Space                |
| Brave browser                | Super+B                      |
| Terminal (Alacritty)         | Super+Enter                  |
| File manager (Thunar)        | Super+E                      |
| Task Manager GUI (LXTASK)    | Ctrl+Shift+Esc               |
| Power menu                   | Super+Shift+Q                |
| Wallpaper Changer            | Super+Shift+W                |
| Tabbed layout toggle         | Super+T                      |
| Floating/Tilind layout toggle| Super+Shift+Space            |
| Lock screen                  | Super+Ctrl+Shift+L           |
| Screenshot                   | Super+Shift+S                |
| Volume Up                    | XF86AudioRaiseVolume / Super+Shift+Right |
| Volume Down                  | XF86AudioLowerVolume / Super+Shift+Left |
| Mute Toggle                  | XF86AudioMute / Super+Shift+M |
| Brightness Up                | XF86MonBrightnessUp / Super+Shift+Up |
| Brightness Down              | XF86MonBrightnessDown / Super+Shift+Down |
| Fullscreen toggle            | Super+F                      |
| Close window                 | Super+Q                      |
| Keyboard layout toggle       | Alt+Shift                    |
| Media Play/Pause             | XF86AudioPlay                |
| Media Next                   | XF86AudioNext                |
| Media Previous               | XF86AudioPrev                |
| Display CheatSheet           | Super+Shift+C                |

---

## Installation

Method 1 - Install using wget (install wget with ```sudo pacman -S wget```):
- For hyprland:
  ```sudo wget -qO - https://raw.githubusercontent.com/FatihTheDev/archlinux-tiling-wm-config/main/hyprland-setup.sh | bash```
- For sway:
  ```sudo wget -qO - https://raw.githubusercontent.com/FatihTheDev/archlinux-tiling-wm-config/main/sway-setup.sh | bash```

Note: This is a capital letter o, not a zero.

Method 2 - Install by cloning the git repository:

1. **Clone the repository:**
```bash
git clone https://github.com/FatihTheDev/archlinux-sway-config.git
cd archlinux-sway-config
```
2. **Run the setup script:**
- For hyprland:
  ```bash
  bash hyprland-setup.sh
  ```
- For sway:
  ```bash
  bash sway-setup.sh
  ```

The script will install all required packages, configure Sway/Hyprland, Waybar, Wofi, bluetooth, smart volume & brightness keys, and set up GUI utilities.

3.**Restart the machine to apply all changes.**

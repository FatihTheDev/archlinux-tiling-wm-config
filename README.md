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

- **Wofi** as an app launcher on `Mod + Space` keys
- **Power menu** with Poweroff, Reboot, Logout via `Mod + Shift + Q`  
- **Browsers**:
  - LibreWolf → `Mod+B`
- **Terminal** → `Mod+Enter` (Alacritty)  
- **File manager** → `Mod+E` (Thunar)
- **GTK App Theme Settings** → `Mod+Shift+T`
- **Task Manager GUI** → `Ctrl+Shift+Esc` (LXTASK)  
- **Keyboard layouts**: Bosnian (`ba`) and English (`us`), switched with `SUperKey+Space`  
- **Screenshot tool** → `Mod+Shift+S`  
- **Volume controls**:
  - XF86 hardware keys supported  
  - Smart fallback keys if hardware keys fail: `Mod+Shift+Right` (volume up), `Mod+Shift+Left` (volume down), `Mod+Shift+M` (mute)  
- **Brightness controls**:
  - XF86 hardware keys supported  
  - Smart fallback keys if hardware keys fail: `Mod+Shift+Up` (increase), `Mod+Shift+Down` (decrease)  
  - Default brightness set to **15%**  
- **Wallpaper Changer (need to have an image in ~/Pictures/Wallpapers)** → `Mod+Shift+W`
- **Tabbed layout toggle (Hyprland doesn't support tabbed layout)** -> `Mod+T`
- **Floating/Tilind layouts toggle** -> `Mod+Shift+Space`
- **Lock screen** -> `Mod+Ctrl+Shift+L`
- **Media keys**: Play/Pause, Next, Previous (via Playerctl)
- **Display CheatSheet of all keybindings** -> `Mod+Shift+C`

---

## Keybindings Overview

| Action                      | Keybinding                  |
|------------------------------|----------------------------|
| App launcher (Wofi)          | Mod + Space                |
| Librewolf browser            | Mod+B                      |
| Terminal (Alacritty)         | Mod+Enter                  |
| File manager (Thunar)        | Mod+E                      |
| Task Manager GUI (LXTASK)    | Ctrl+Shift+Esc             |
| Power menu                   | Mod+Shift+Q                |
| Wallpaper Changer            | Mod+Shift+W                |
| Tabbed layout toggle(for Sway) | Mod+T                      |
| Floating/Tilind layout toggle| Mod+Shift+Space            |
| Lock screen                  | Mod+Ctrl+Shift+L           |
| Screenshot                   | Mod+Shift+S                |
| Volume Up                    | XF86AudioRaiseVolume / Mod+Shift+Right |
| Volume Down                  | XF86AudioLowerVolume / Mod+Shift+Left |
| Mute Toggle                  | XF86AudioMute / Mod+Shift+M |
| Brightness Up                | XF86MonBrightnessUp / Mod+Shift+Up |
| Brightness Down              | XF86MonBrightnessDown / Mod+Shift+Down |
| Fullscreen toggle            | Mod+F                      |
| Close window                 | Mod+Q                      |
| Keyboard layout toggle       | Super+Space                |
| Media Play/Pause             | XF86AudioPlay              |
| Media Next                   | XF86AudioNext              |
| Media Previous               | XF86AudioPrev              |
| Display CheatSheet           | Mod+Shift+C                |

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

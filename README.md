# WPM Waybar Widget

Live words-per-minute typing speed monitor for Waybar on Wayland.

Reads keyboard events via evdev and displays your typing speed directly in Waybar with three modules:

- **wpm-live** -- real-time WPM updated every 200ms while you type
- **wpm-burst** -- WPM from your last completed typing burst
- **wpm-avg** -- session average across all bursts

Right-click any module to reset the session.

![screenshot](screenshot.png)

## Prerequisites

- **Wayland** compositor (Hyprland, Sway, etc.)
- **Waybar**
- **Python 3**
- **python-evdev** -- `sudo pacman -S python-evdev` (Arch) / `sudo apt install python3-evdev` (Debian) / `pip install evdev`
- Your user must be in the **input** group: `sudo usermod -aG input $USER` (log out and back in)

## Install

```sh
git clone https://github.com/YOUR_USER/wpm-waybar.git
cd wpm-waybar
bash install.sh
```

The installer copies the scripts to `~/.local/bin/` and checks dependencies. It will not modify your Waybar config automatically -- you do that part manually (see below).

## Waybar Configuration

### 1. Add the modules

Open `~/.config/waybar/config.jsonc` and add the modules where you want them, e.g.:

```jsonc
"modules-center": ["clock", "custom/wpm-live", "custom/wpm-burst", "custom/wpm-avg"]
```

### 2. Add the module definitions

Add these inside your top-level config object:

```jsonc
"custom/wpm-live": {
    "exec": "~/.local/bin/wpm-monitor",
    "return-type": "json",
    "on-click-right": "pkill -USR1 -f wpm-monitor",
    "tooltip": true
},
"custom/wpm-burst": {
    "exec": "~/.local/bin/wpm-status burst",
    "return-type": "json",
    "on-click-right": "pkill -USR1 -f wpm-monitor",
    "interval": 1,
    "tooltip": true
},
"custom/wpm-avg": {
    "exec": "~/.local/bin/wpm-status avg",
    "return-type": "json",
    "on-click-right": "pkill -USR1 -f wpm-monitor",
    "interval": 1,
    "tooltip": true
}
```

### 3. Add the styles

Append to your waybar `style.css`:

```css
#custom-wpm-live,
#custom-wpm-burst,
#custom-wpm-avg {
    min-width: 12px;
    margin: 0 3px;
}

#custom-wpm-live.active {
    color: #f38d70;
}

#custom-wpm-live.idle,
#custom-wpm-burst.no-data,
#custom-wpm-avg.no-data {
    opacity: 0.5;
}

#custom-wpm-live.error {
    opacity: 0.4;
}
```

### 4. Restart Waybar

```sh
killall waybar && waybar &
```

## Usage

Once configured, the modules appear in your Waybar:

| Module | Idle | Active |
|--------|------|--------|
| wpm-live | `󰌌` (dimmed) | `󰌌 85` (orange) |
| wpm-burst | `↯` (dimmed) | `↯ 92` |
| wpm-avg | `⌀` (dimmed) | `⌀ 78` |

- **Typing** triggers live WPM calculation in real time
- **Pausing** for 2 seconds ends the current burst
- **Right-click** any module to reset session stats
- **Hover** any module for a tooltip with session details

## How It Works

`wpm-monitor` is a persistent daemon that reads raw key events from `/dev/input/` via evdev. It detects typing bursts (separated by 2s of inactivity), calculates WPM using the standard 5-characters-per-word formula, and outputs JSON for Waybar's `custom` module protocol. It also writes state to `/tmp/wpm-monitor.json` so the burst/avg modules can read it independently.

## Uninstall

```sh
cd wpm-waybar
bash uninstall.sh
```

Then remove the WPM entries from your Waybar config and style manually.

## License

MIT

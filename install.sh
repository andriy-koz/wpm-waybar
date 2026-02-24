#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"

echo "=== WPM Waybar Widget Installer ==="
echo

# Check prerequisites
errors=0

if ! command -v python3 &>/dev/null; then
    echo "[ERROR] python3 not found. Install Python 3 first."
    errors=1
fi

if ! python3 -c "import evdev" &>/dev/null; then
    echo "[ERROR] python-evdev not found."
    echo "        Install it with your package manager:"
    echo "          Arch:   sudo pacman -S python-evdev"
    echo "          Debian: sudo apt install python3-evdev"
    echo "          Fedora: sudo dnf install python3-evdev"
    echo "          pip:    pip install evdev"
    errors=1
else
    echo "[OK] python-evdev found"
fi

VENV_DIR="$HOME/.local/share/wpm-venv"
if ! python3 -c "import plotext" &>/dev/null; then
    echo "[INFO] plotext not found system-wide, creating venv..."
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install --quiet plotext
    echo "[OK] plotext installed in $VENV_DIR"
else
    echo "[OK] plotext found"
fi

if ! groups | grep -qw input; then
    echo "[WARN] Your user is not in the 'input' group."
    echo "       Run: sudo usermod -aG input $USER"
    echo "       Then log out and back in."
    echo "       (The monitor cannot read keyboard events without this.)"
else
    echo "[OK] User is in 'input' group"
fi

if ! command -v waybar &>/dev/null; then
    echo "[WARN] waybar not found in PATH."
fi

if [ "$errors" -ne 0 ]; then
    echo
    echo "Fix the errors above and re-run install.sh"
    exit 1
fi

echo

# Install scripts
mkdir -p "$INSTALL_DIR"

install -m 755 "$SCRIPT_DIR/wpm-monitor" "$INSTALL_DIR/wpm-monitor"
echo "Installed wpm-monitor -> $INSTALL_DIR/wpm-monitor"

install -m 755 "$SCRIPT_DIR/wpm-status" "$INSTALL_DIR/wpm-status"
echo "Installed wpm-status  -> $INSTALL_DIR/wpm-status"

install -m 755 "$SCRIPT_DIR/wpm-chart" "$INSTALL_DIR/wpm-chart"
echo "Installed wpm-chart   -> $INSTALL_DIR/wpm-chart"

# Install Neovim plugin (optional)
NVIM_PLUGINS_DIR="$HOME/.config/nvim/lua/plugins"
if [ -d "$NVIM_PLUGINS_DIR" ]; then
    cp "$SCRIPT_DIR/nvim/wpm-mode.lua" "$NVIM_PLUGINS_DIR/wpm-mode.lua"
    echo "Installed wpm-mode.lua -> $NVIM_PLUGINS_DIR/wpm-mode.lua"
else
    echo "[INFO] Neovim plugins dir not found ($NVIM_PLUGINS_DIR)"
    echo "       To filter nvim navigation from WPM, manually copy:"
    echo "         cp nvim/wpm-mode.lua ~/.config/nvim/lua/plugins/"
fi

# Kill any old instance
pkill -f "wpm-monitor" 2>/dev/null && echo "Stopped old wpm-monitor process" || true

echo
echo "=== Scripts installed! ==="
echo
echo "Next, add the WPM modules to your Waybar config manually:"
echo
echo "  1. Open ~/.config/waybar/config.jsonc"
echo "  2. Add these modules where you want them (e.g. modules-center):"
echo '     "custom/wpm-live", "custom/wpm-burst", "custom/wpm-avg"'
echo "  3. Add the module definitions from: waybar/config.jsonc"
echo "  4. Add the styles from: waybar/style.css to your waybar style.css"
echo "  5. Restart Waybar: killall waybar && waybar &"
echo
echo "For Hyprland floating chart window, add to hyprland.conf:"
echo '  windowrule = float on, match:class ^(wpm-chart)$'
echo '  windowrule = size 900 500, match:class ^(wpm-chart)$'
echo '  windowrule = center on, match:class ^(wpm-chart)$'
echo

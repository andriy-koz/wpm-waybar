#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"

echo "=== WPM Waybar Widget Uninstaller ==="
echo

# Stop running monitor
if pkill -f "wpm-monitor" 2>/dev/null; then
    echo "Stopped running wpm-monitor"
fi

# Remove state file
rm -f /tmp/wpm-monitor.json /tmp/wpm-monitor.json.tmp
echo "Cleaned up state files"

# Remove scripts
for script in wpm-monitor wpm-status; do
    if [ -f "$INSTALL_DIR/$script" ]; then
        rm "$INSTALL_DIR/$script"
        echo "Removed $INSTALL_DIR/$script"
    fi
done

echo
echo "=== Scripts removed! ==="
echo
echo "To finish cleanup, remove the WPM entries from your Waybar config:"
echo
echo "  1. Open ~/.config/waybar/config.jsonc"
echo '  2. Remove "custom/wpm-live", "custom/wpm-burst", "custom/wpm-avg" from modules-center'
echo '  3. Remove the "custom/wpm-live", "custom/wpm-burst", "custom/wpm-avg" module definitions'
echo "  4. Open your waybar style.css and remove the #custom-wpm-* rules"
echo "  5. Restart Waybar: killall waybar && waybar &"
echo

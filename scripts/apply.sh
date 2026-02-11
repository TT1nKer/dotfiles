#!/usr/bin/env bash
set -euo pipefail

# Hyprland reload (if running)
if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi

# Restart waybar (if running)
pkill waybar >/dev/null 2>&1 || true
nohup waybar >/dev/null 2>&1 &

echo "Applied: hypr reload + waybar restart"

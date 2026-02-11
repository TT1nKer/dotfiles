#!/usr/bin/env bash
set -euo pipefail

# Hyprland reload (if running)
if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi

# Restart waybar (if running)
pkill waybar >/dev/null 2>&1 || true
nohup waybar >/dev/null 2>&1 &

# Reload zsh config (if current shell is zsh)
if [ -n "${ZSH_VERSION-}" ]; then
  source "${HOME}/.zshrc" >/dev/null 2>&1 || true
fi

echo "Applied: hypr reload + waybar restart + zsh reload(if zsh)"

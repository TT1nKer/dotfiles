#!/usr/bin/env bash
set -euo pipefail

DOT="${HOME}/.dotfiles"
CFG="${HOME}/.config"

mkdir -p "${CFG}"

for d in hypr waybar kitty rofi; do
  rm -rf "${CFG:?}/${d}"
  ln -s "${DOT}/${d}" "${CFG}/${d}"
done

echo "Linked: hypr waybar kitty rofi"

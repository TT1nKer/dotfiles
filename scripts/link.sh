#!/usr/bin/env bash
set -euo pipefail

DOT="${HOME}/.dotfiles"
CFG="${HOME}/.config"
BK="${HOME}/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

mkdir -p "${CFG}" "${BK}"

# ---------- helpers ----------
backup_target() {
  local target="$1"

  # symlink: remove it (no backup needed)
  if [ -L "$target" ]; then
    rm -f "$target"
    return 0
  fi

  # real file/dir: move to backup
  if [ -e "$target" ]; then
    local rel="${target#$HOME/}"   # relative path under $HOME
    mkdir -p "${BK}/$(dirname "$rel")"
    mv "$target" "${BK}/${rel}"
  fi
}

link_path() {
  local src="$1"
  local dst="$2"

  if [ ! -e "$src" ]; then
    echo "Skip (missing): $src"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  backup_target "$dst"
  ln -s "$src" "$dst"
  echo "Linked: $dst -> $src"
}

# ---------- what to link ----------
# A) .config dirs: ~/.config/<name> -> ~/.dotfiles/<name>
CONFIG_DIRS=(hypr waybar kitty rofi starship.toml)

# B) home files: ~/.<name> -> ~/.dotfiles/<group>/<file>
# format: "DEST_REL:SOURCE_REL"
HOME_LINKS=(
  ".zshrc:zsh/zshrc"
)

# ---------- run ----------
for d in "${CONFIG_DIRS[@]}"; do
  link_path "${DOT}/${d}" "${CFG}/${d}"
done

for item in "${HOME_LINKS[@]}"; do
  dst_rel="${item%%:*}"
  src_rel="${item#*:}"
  link_path "${DOT}/${src_rel}" "${HOME}/${dst_rel}"
done

echo "Done. Backup (if any): ${BK}"
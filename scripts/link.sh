#!/usr/bin/env bash
set -euo pipefail

DOT="${HOME}/.dotfiles"
CFG="${HOME}/.config"
BK="${HOME}/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

mkdir -p "${CFG}" "${BK}"

log() { printf '%s\n' "$*"; }

# ---------- helpers ----------
backup_target() {
  local target="$1"

  # if it's a symlink (even dangling), remove it; no backup needed
  if [ -L "$target" ]; then
    rm -f "$target"
    return 0
  fi

  # if it's a real file/dir, move it to backup
  if [ -e "$target" ]; then
    local rel="${target#$HOME/}"   # path relative to $HOME
    mkdir -p "${BK}/$(dirname "$rel")"
    mv "$target" "${BK}/${rel}"
  fi
}

link_path() {
  local src="$1"
  local dst="$2"

  # src must exist (real file/dir); otherwise skip to avoid dangling links
  if [ ! -e "$src" ]; then
    log "Skip (missing): $src"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  backup_target "$dst"

  ln -s "$src" "$dst"
  log "Linked: $dst -> $src"
}

# Map format: "DST:SR C"
# If DST starts with ".config/", it will be under ~/.config/
# Otherwise it's relative to $HOME (e.g. ".zshrc")
apply_map() {
  local entry="$1"
  local dst_rel="${entry%%:*}"
  local src_rel="${entry#*:}"

  local dst
  if [[ "$dst_rel" == .config/* ]]; then
    dst="${HOME}/${dst_rel}"      # already includes .config/...
  else
    dst="${HOME}/${dst_rel}"
  fi

  link_path "${DOT}/${src_rel}" "${dst}"
}

# ---------- what to link ----------
# Put EVERYTHING here, easy to extend later.
# Left side: destination relative to $HOME
# Right side: source relative to $DOT
LINK_MAP=(
  # --- config dirs ---
  ".config/hypr:hypr"
  ".config/waybar:waybar"
  ".config/kitty:kitty"
  ".config/rofi:rofi"

  # --- single config files ---
  ".config/starship.toml:starship/starship.toml"

  # --- home dotfiles ---
  ".zshrc:zsh/zshrc"

  #niri
  ".config/niri:niri"
)

# ---------- run ----------
for entry in "${LINK_MAP[@]}"; do
  apply_map "$entry"
done

log "Done. Backup (if any): ${BK}"

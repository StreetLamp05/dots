#!/usr/bin/env bash
# install.sh — deploy dotfiles into ~/.config (and $HOME) on a new machine.
#
# For each tool it checks the relevant package/binary is installed; if so it
# backs up any existing config and copies the tracked files into place. If the
# package is missing, that tool is skipped.
#
# Usage:
#   ./install.sh            # install everything whose package is present
#   ./install.sh --dry-run  # show what would happen, change nothing
#   ./install.sh --force    # install even if the package isn't detected

set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

c_grn=$'\e[32m'; c_yel=$'\e[33m'; c_red=$'\e[31m'; c_dim=$'\e[2m'; c_rst=$'\e[0m'
installed=(); skipped=()

have() { command -v "$1" >/dev/null 2>&1; }

# run CMD, or just print it under --dry-run
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "    ${c_dim}would: $*${c_rst}"
  else
    "$@"
  fi
}

# copy_into SRC DEST — copy a file or directory's contents to DEST,
# backing up anything already there.
copy_into() {
  local src="$1" dest="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "    backup: $dest -> $dest.bak-$STAMP"
    run mv "$dest" "$dest.bak-$STAMP"
  fi
  run mkdir -p "$(dirname "$dest")"
  run cp -r "$src" "$dest"
  echo "    ${c_grn}placed${c_rst}: $dest"
}

# deploy NAME BINARY -- SRC1:DEST1 SRC2:DEST2 ...
# BINARY is the command checked with `command -v`.
deploy() {
  local name="$1" binary="$2"; shift 3   # shift past name, binary, "--"
  echo "${c_yel}==>${c_rst} $name"
  if ! have "$binary" && [[ $FORCE -eq 0 ]]; then
    echo "    ${c_red}skip${c_rst}: '$binary' not found on PATH"
    skipped+=("$name")
    return
  fi
  local pair src dest
  for pair in "$@"; do
    src="$DOTS/${pair%%:*}"
    dest="${pair##*:}"
    dest="${dest/#\~/$HOME}"
    if [[ ! -e "$src" ]]; then
      echo "    ${c_red}missing in repo${c_rst}: $src"
      continue
    fi
    copy_into "$src" "$dest"
  done
  installed+=("$name")
}

echo "dotfiles: $DOTS"
echo "target:   $CONFIG"
[[ $DRY_RUN -eq 1 ]] && echo "${c_dim}(dry run — nothing will be changed)${c_rst}"
echo

deploy "niri" niri -- \
  "niri/config.kdl:$CONFIG/niri/config.kdl" \
  "niri/dms:$CONFIG/niri/dms"

deploy "alacritty" alacritty -- \
  "alacritty/alacritty.toml:$CONFIG/alacritty/alacritty.toml" \
  "alacritty/dank-theme.toml:$CONFIG/alacritty/dank-theme.toml"

deploy "kitty" kitty -- \
  "kitty/kitty.conf:$CONFIG/kitty/kitty.conf" \
  "kitty/dank-tabs.conf:$CONFIG/kitty/dank-tabs.conf" \
  "kitty/dank-theme.conf:$CONFIG/kitty/dank-theme.conf" \
  "kitty/light-theme.auto.conf:$CONFIG/kitty/light-theme.auto.conf"

deploy "fish" fish -- \
  "fish/config.fish:$CONFIG/fish/config.fish" \
  "fish/functions:$CONFIG/fish/functions"

deploy "cava" cava -- \
  "cava/config:$CONFIG/cava/config" \
  "cava/themes:$CONFIG/cava/themes" \
  "cava/shaders:$CONFIG/cava/shaders"

deploy "micro" micro -- \
  "micro/settings.json:$CONFIG/micro/settings.json"

# DankMaterialShell ships its CLI as `dms`.
deploy "DankMaterialShell" dms -- \
  "DankMaterialShell/settings.json:$CONFIG/DankMaterialShell/settings.json" \
  "DankMaterialShell/firefox.css:$CONFIG/DankMaterialShell/firefox.css"

# environment.d is read by systemd --user; no package gate, always relevant.
deploy "environment.d" sh -- \
  "environment.d/90-dms.conf:$CONFIG/environment.d/90-dms.conf"

deploy "git (ignore)" git -- \
  "git/ignore:$CONFIG/git/ignore"

deploy "bash" bash -- \
  "home/.bashrc:$HOME/.bashrc"

deploy "zsh" zsh -- \
  "home/.zshrc:$HOME/.zshrc"

echo
echo "${c_grn}installed:${c_rst} ${installed[*]:-(none)}"
echo "${c_yel}skipped:${c_rst}   ${skipped[*]:-(none)}"
[[ $DRY_RUN -eq 1 ]] && echo "${c_dim}(dry run — re-run without --dry-run to apply)${c_rst}"
echo "backups of replaced files use the suffix .bak-$STAMP"

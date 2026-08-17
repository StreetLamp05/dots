#!/usr/bin/env bash
# Toggle the focused window's scroller-layout width between 100% and whatever
# it was before — like niri's maximize-column. Unlike togglemaximizescreen,
# this writes the real scroller_proportion, so it survives a native
# app-fullscreen (e.g. a video player) cycling in and out.
set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/mango-proportion-state"
mkdir -p "$STATE_DIR"

info="$(mmsg get focusing-client)"
id="$(jq -r '.id' <<<"$info")"
current="$(jq -r '.scroller_proportion // 0.5' <<<"$info")"
state_file="$STATE_DIR/$id"

if awk -v c="$current" 'BEGIN{exit !(c >= 0.99)}'; then
  prev="0.5"
  [[ -f "$state_file" ]] && prev="$(cat "$state_file")"
  rm -f "$state_file"
  mmsg dispatch set_proportion,"$prev"
else
  echo "$current" >"$state_file"
  mmsg dispatch set_proportion,1.0
fi

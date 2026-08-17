#!/usr/bin/env bash
# Adjust the focused window's scroller-layout width by a relative step.
# Usage: adjust-proportion.sh +0.1   |   adjust-proportion.sh -0.1
set -euo pipefail

delta="${1:?usage: adjust-proportion.sh +0.1|-0.1}"
current="$(mmsg get focusing-client | jq -r '.scroller_proportion // 0.5')"

new="$(awk -v c="$current" -v d="$delta" 'BEGIN {
  v = c + d
  if (v < 0.1) v = 0.1
  if (v > 1.0) v = 1.0
  printf "%.2f", v
}')"

mmsg dispatch set_proportion,"$new"

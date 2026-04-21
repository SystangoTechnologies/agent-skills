#!/usr/bin/env bash
# Remove all agent-skills symlinks from ~/.cursor, detach the sessionStart
# hook, and optionally delete the plugin checkout.
#
# Usage:
#   ./scripts/uninstall-cursor.sh           # remove symlinks + hook entry, keep checkout
#   ./scripts/uninstall-cursor.sh --purge   # also delete ~/.cursor/plugins/agent-skills
#   ./scripts/uninstall-cursor.sh --dir=PATH

set -euo pipefail

CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
PURGE=0

for arg in "$@"; do
  case "$arg" in
    --purge)  PURGE=1 ;;
    --dir=*)  CURSOR_HOME="${arg#*=}" ;;
    -h|--help)
      sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
  esac
done

PLUGIN_DIR="$CURSOR_HOME/plugins/agent-skills"
if [[ -d "$PLUGIN_DIR" ]]; then
  PLUGIN_DIR_CANON="$(cd "$PLUGIN_DIR" && pwd -P)"
else
  PLUGIN_DIR_CANON="$PLUGIN_DIR"
fi

log() { printf '[uninstall] %s\n' "$*"; }

abs_target() {
  local link="$1" t dir base
  t="$(readlink "$link")" || return 1
  case "$t" in
    /*) : ;;
    *)  t="$(cd "$(dirname "$link")" && pwd -P)/$t" ;;
  esac
  dir="$(dirname "$t")"
  base="$(basename "$t")"
  if [[ -d "$dir" ]]; then
    printf '%s/%s' "$(cd "$dir" && pwd -P)" "$base"
  else
    printf '%s' "$t"
  fi
}

for base in skills commands agents; do
  dir="$CURSOR_HOME/$base"
  [[ -d "$dir" ]] || continue
  shopt -s nullglob
  for link in "$dir"/*; do
    if [[ -L "$link" ]]; then
      target="$(abs_target "$link" || true)"
      case "$target" in
        "$PLUGIN_DIR"/*|"$PLUGIN_DIR_CANON"/*)
          rm -f -- "$link"
          log "removed $link"
          ;;
      esac
    fi
  done
  shopt -u nullglob
done

if [[ -f "$CURSOR_HOME/hooks.json" && -f "$PLUGIN_DIR/scripts/lib/hooks-merge.py" ]]; then
  python3 "$PLUGIN_DIR/scripts/lib/hooks-merge.py" uninstall \
    --hooks-file "$CURSOR_HOME/hooks.json" \
    --command    "$PLUGIN_DIR/hooks/cursor-session-start.sh" || true
fi

if [[ "$PURGE" == 1 ]]; then
  rm -rf -- "$PLUGIN_DIR"
  log "removed $PLUGIN_DIR"
else
  log "left plugin checkout at $PLUGIN_DIR (pass --purge to delete)"
fi

log "done"

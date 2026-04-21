#!/usr/bin/env bash
# Mirror the repo's canonical skills/commands/agents into
# ~/.cursor/{skills,commands,agents} via symlinks.
#
# Source (in this repo) -> Destination (~/.cursor):
#   skills/<name>/           ->  skills/<name>/
#   .claude/commands/<x>.md  ->  commands/<x>.md
#   agents/<x>.md            ->  agents/<x>.md
#
# Called by install-cursor.sh and by the sessionStart hook after a successful
# self-update. Safe to re-run; only touches symlinks that point back into
# this plugin directory (so unrelated user content is never modified).
#
# Env / flags:
#   CURSOR_HOME   override ~/.cursor   (default: $HOME/.cursor)
#   FORCE=1       overwrite non-symlink entries with the same name
#   --force|-f    same as FORCE=1
#   --quiet       suppress info logs (warnings still go to stderr)

set -euo pipefail

CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
FORCE="${FORCE:-0}"
QUIET=0

for arg in "$@"; do
  case "$arg" in
    --force|-f)  FORCE=1 ;;
    --quiet|-q)  QUIET=1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

log()  { [[ "$QUIET" == 1 ]] || printf '[sync] %s\n' "$*"; }
warn() { printf '[sync] WARN: %s\n' "$*" >&2; }

# Canonicalize a symlink's target to an absolute, fully-resolved path
# (portable — avoids readlink -f / GNU coreutils).
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

link_entries() {
  # link_entries <src_dir> <dst_dir>
  # Creates/refreshes a symlink in dst for every direct child of src,
  # and prunes stale symlinks that used to point into this plugin.
  local src="$1" dst="$2"
  mkdir -p "$dst"
  [[ -d "$src" ]] || return 0

  local entry name target current
  shopt -s nullglob dotglob
  for entry in "$src"/*; do
    name="$(basename "$entry")"
    [[ "$name" == .* ]] && continue   # skip dotfiles like .DS_Store
    target="$dst/$name"

    if [[ -L "$target" ]]; then
      current="$(abs_target "$target" || true)"
      if [[ "$current" != "$entry" ]]; then
        ln -sfn "$entry" "$target"
        log "relinked $target"
      fi
    elif [[ -e "$target" ]]; then
      if [[ "$FORCE" == "1" ]]; then
        rm -rf -- "$target"
        ln -s "$entry" "$target"
        log "overwrote $target"
      else
        warn "skipping $target (exists, not a symlink). Use --force to overwrite."
      fi
    else
      ln -s "$entry" "$target"
      log "linked $target"
    fi
  done
  shopt -u nullglob dotglob

  # Prune our own stale symlinks (target points inside plugin dir but is missing).
  local link t
  shopt -s nullglob
  for link in "$dst"/*; do
    [[ -L "$link" ]] || continue
    t="$(abs_target "$link" || true)"
    case "$t" in
      "$PLUGIN_DIR"/*)
        if [[ ! -e "$t" ]]; then
          rm -f -- "$link"
          log "pruned stale $link"
        fi
        ;;
    esac
  done
  shopt -u nullglob
}

link_entries "$PLUGIN_DIR/skills"          "$CURSOR_HOME/skills"
link_entries "$PLUGIN_DIR/.claude/commands" "$CURSOR_HOME/commands"
link_entries "$PLUGIN_DIR/agents"          "$CURSOR_HOME/agents"

log "synced skills/commands/agents into $CURSOR_HOME"

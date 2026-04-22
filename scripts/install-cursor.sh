#!/usr/bin/env bash
# agent-skills: install into the global ~/.cursor directory so every Cursor
# project on this machine automatically sees the skills, slash commands,
# agent personas, and sessionStart hook — the same way a Claude plugin works.
#
# Usage:
#   ./scripts/install-cursor.sh                # install from local checkout or clone from GitHub
#   AGENT_SKILLS_REPO=<url> ./scripts/install-cursor.sh
#   AGENT_SKILLS_REF=<branch|tag|sha> ./scripts/install-cursor.sh
#   ./scripts/install-cursor.sh --force        # overwrite non-symlink entries with same names
#   ./scripts/install-cursor.sh --dir=PATH     # override Cursor home (default: ~/.cursor)
#   ./scripts/install-cursor.sh --ref=REF      # shorthand for AGENT_SKILLS_REF
#
# Re-running is safe; it fast-forwards the checkout and re-syncs symlinks. If a
# different ref is requested than the one currently checked out, the script
# switches the clone to the new ref.

set -euo pipefail

REPO_URL="${AGENT_SKILLS_REPO:-https://github.com/SystangoTechnologies/agent-skills.git}"
REPO_REF="${AGENT_SKILLS_REF:-}"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
PLUGIN_NAME="agent-skills"
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
    --dir=*)    CURSOR_HOME="${arg#*=}" ;;
    --ref=*)    REPO_REF="${arg#*=}" ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) printf 'Unknown arg: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

PLUGIN_DIR="$CURSOR_HOME/plugins/$PLUGIN_NAME"

log()  { printf '[install] %s\n' "$*"; }
warn() { printf '[install] WARN: %s\n' "$*" >&2; }
die()  { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }

command -v git     >/dev/null || die "git is required"
command -v python3 >/dev/null || die "python3 is required (used for JSON merge)"

mkdir -p "$CURSOR_HOME"/{plugins,skills,commands,agents,hooks}

# Detect whether the installer is being run from inside a local checkout
# (fast path: clone from the local path) vs streamed via `bash <(curl ...)`
# or `curl ... | bash` where $0 is a process-substitution FD or the bash
# interpreter itself. In the streamed case, skip detection silently and
# fall through to the network clone.
SOURCE_REPO=""
if [[ -f "$0" && -r "$0" ]]; then
  CANDIDATE="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd -P)" || CANDIDATE=""
  if [[ -n "$CANDIDATE" && -f "$CANDIDATE/skills/using-agent-skills/SKILL.md" ]]; then
    SOURCE_REPO="$CANDIDATE"
  fi
fi

if [[ -d "$PLUGIN_DIR/.git" ]]; then
  log "updating existing checkout at $PLUGIN_DIR"
  git -C "$PLUGIN_DIR" fetch --quiet --tags origin || warn "git fetch failed; continuing"
  if [[ -n "$REPO_REF" ]]; then
    log "checking out ref: $REPO_REF"
    git -C "$PLUGIN_DIR" checkout --quiet "$REPO_REF" || die "failed to checkout '$REPO_REF'"
    git -C "$PLUGIN_DIR" pull --ff-only --quiet 2>/dev/null || true
  else
    git -C "$PLUGIN_DIR" pull --ff-only --quiet || warn "git pull failed; continuing with existing checkout"
  fi
elif [[ -n "$SOURCE_REPO" && -d "$SOURCE_REPO/.git" ]]; then
  log "cloning local checkout $SOURCE_REPO -> $PLUGIN_DIR"
  git clone --quiet "$SOURCE_REPO" "$PLUGIN_DIR"
  git -C "$PLUGIN_DIR" remote set-url origin "$REPO_URL" 2>/dev/null || true
  if [[ -n "$REPO_REF" ]]; then
    log "checking out ref: $REPO_REF"
    git -C "$PLUGIN_DIR" fetch --quiet --tags origin || true
    git -C "$PLUGIN_DIR" checkout --quiet "$REPO_REF" || die "failed to checkout '$REPO_REF'"
  fi
else
  if [[ -n "$REPO_REF" ]]; then
    log "cloning $REPO_URL (ref: $REPO_REF) -> $PLUGIN_DIR"
    git clone --quiet --branch "$REPO_REF" "$REPO_URL" "$PLUGIN_DIR" 2>/dev/null \
      || { git clone --quiet "$REPO_URL" "$PLUGIN_DIR" \
           && git -C "$PLUGIN_DIR" checkout --quiet "$REPO_REF"; } \
      || die "failed to clone $REPO_URL at ref '$REPO_REF'"
  else
    log "cloning $REPO_URL -> $PLUGIN_DIR"
    git clone --quiet "$REPO_URL" "$PLUGIN_DIR"
  fi
fi

chmod +x "$PLUGIN_DIR/scripts/sync-cursor.sh" "$PLUGIN_DIR/scripts/uninstall-cursor.sh" \
         "$PLUGIN_DIR/hooks/cursor-session-start.sh" 2>/dev/null || true

CURSOR_HOME="$CURSOR_HOME" FORCE="$FORCE" "$PLUGIN_DIR/scripts/sync-cursor.sh"

python3 "$PLUGIN_DIR/scripts/lib/hooks-merge.py" install \
  --hooks-file "$CURSOR_HOME/hooks.json" \
  --command    "$PLUGIN_DIR/hooks/cursor-session-start.sh"

log "done."
log "restart Cursor (or start a new agent session) to load the meta-skill."
log "to update manually:   git -C $PLUGIN_DIR pull && $PLUGIN_DIR/scripts/sync-cursor.sh"
log "to uninstall:         $PLUGIN_DIR/scripts/uninstall-cursor.sh [--purge]"

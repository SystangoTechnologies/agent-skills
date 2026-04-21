#!/usr/bin/env bash
# Cursor sessionStart hook — injects the using-agent-skills meta-skill into
# every new Cursor agent session and, when running from a git checkout (the
# global install at ~/.cursor/plugins/agent-skills), triggers a throttled,
# fully backgrounded self-update so subsequent sessions pick up upstream
# changes automatically — mirroring how Claude Code plugins auto-update.
#
# Contract: reads Cursor's session JSON on stdin, writes a JSON object with
# an `additional_context` field to stdout. Any diagnostic output goes to
# stderr so it won't corrupt the hook's response.

set -euo pipefail

cat >/dev/null 2>&1 || true   # drain Cursor's session-metadata payload

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
META_SKILL="$REPO_ROOT/skills/using-agent-skills/SKILL.md"

# --- Self-update (only when this checkout is a git repo) -------------------
# Throttled to once per AGENT_SKILLS_UPDATE_INTERVAL seconds (default 6h).
# Runs fully detached so it never slows down session startup.
UPDATE_INTERVAL="${AGENT_SKILLS_UPDATE_INTERVAL:-21600}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agent-skills"
STAMP="$STATE_DIR/last-update"

if [[ "${AGENT_SKILLS_AUTO_UPDATE:-1}" == "1" && -d "$REPO_ROOT/.git" ]]; then
  mkdir -p "$STATE_DIR" 2>/dev/null || true
  now=$(date +%s)
  last=0
  [[ -f "$STAMP" ]] && last="$(cat "$STAMP" 2>/dev/null || echo 0)"
  if (( now - last >= UPDATE_INTERVAL )); then
    echo "$now" > "$STAMP" 2>/dev/null || true
    (
      # Detach: close stdio, swallow errors — this must never affect the
      # current session. Pulled skills/commands become visible on the next
      # sessionStart (new symlinks are created, removed ones are pruned).
      exec </dev/null >/dev/null 2>&1
      git -C "$REPO_ROOT" pull --ff-only --quiet || exit 0
      if [[ -x "$REPO_ROOT/scripts/sync-cursor.sh" ]]; then
        "$REPO_ROOT/scripts/sync-cursor.sh" --quiet || true
      fi
    ) &
    disown 2>/dev/null || true
  fi
fi

# --- Emit meta-skill as additional_context ---------------------------------
export AGENT_SKILLS_META="$META_SKILL"
export AGENT_SKILLS_PREFIX="agent-skills loaded. Use the skill discovery flowchart to find the right skill for your task.

"

if [[ -f "$META_SKILL" ]]; then
  python3 <<'PY'
import json, os
path = os.environ["AGENT_SKILLS_META"]
prefix = os.environ["AGENT_SKILLS_PREFIX"]
with open(path, "r", encoding="utf-8") as f:
    content = f.read()
print(json.dumps({"additional_context": prefix + content}, ensure_ascii=False))
PY
else
  python3 -c 'import json; print(json.dumps({"additional_context": "agent-skills: using-agent-skills meta-skill not found. Skills may still be available individually."}))'
fi

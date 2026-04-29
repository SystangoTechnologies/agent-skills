#!/usr/bin/env bash
# Cursor sessionStart hook — injects the using-agent-skills meta-skill into
# every new Cursor agent session and, when running from a git checkout (the
# global install at ~/.cursor/plugins/agent-skills), triggers a fully
# backgrounded version-gated self-update so subsequent sessions pick up upstream
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
# Version-gated: fetch upstream, compare .claude-plugin/plugin.json version,
# and pull only when upstream version is greater than local version.
if [[ "${AGENT_SKILLS_AUTO_UPDATE:-1}" == "1" && -d "$REPO_ROOT/.git" ]]; then
  STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agent-skills"
  UPDATE_LOG="$STATE_DIR/update.log"
  UPDATE_LOG_ENABLED="${AGENT_SKILLS_UPDATE_LOG:-0}"
  (
    # Detach: close stdio, swallow errors — this must never affect the
    # current session. Pulled skills/commands become visible on the next
    # sessionStart (new symlinks are created, removed ones are pruned).
    exec </dev/null >/dev/null 2>&1

    log_update() {
      [[ "$UPDATE_LOG_ENABLED" == "1" ]] || return 0
      mkdir -p "$STATE_DIR" 2>/dev/null || return 0
      printf '[%s] %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*" >>"$UPDATE_LOG" 2>/dev/null || true
    }

    upstream_ref="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
    if [[ -z "$upstream_ref" ]]; then
      upstream_ref="origin/main"
      log_update "no upstream branch configured; defaulting to $upstream_ref"
    fi

    # Refresh upstream refs before reading remote plugin.json.
    git -C "$REPO_ROOT" fetch --quiet || { log_update "fetch failed; skipping update"; exit 0; }

    local_version="$(python3 - <<'PY' "$REPO_ROOT/.claude-plugin/plugin.json"
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        print(json.load(f).get("version", ""))
except Exception:
    print("")
PY
)"

    remote_version="$(git -C "$REPO_ROOT" show "${upstream_ref}:.claude-plugin/plugin.json" 2>/dev/null | python3 - <<'PY'
import json, sys
try:
    print(json.load(sys.stdin).get("version", ""))
except Exception:
    print("")
PY
)"

    log_update "version check upstream=$upstream_ref local=${local_version:-<empty>} remote=${remote_version:-<empty>}"

    should_update="$(python3 - <<'PY' "$local_version" "$remote_version"
import re, sys

local = sys.argv[1] or ""
remote = sys.argv[2] or ""

def parse(v: str):
    m = re.match(r"^\s*(\d+(?:\.\d+)*)(?:[-+]?([0-9A-Za-z.-]+))?\s*$", v)
    if not m:
        return None
    nums = tuple(int(x) for x in m.group(1).split("."))
    suffix = m.group(2) or ""
    return nums, suffix

lv = parse(local)
rv = parse(remote)
if not lv or not rv:
    print("0")
    raise SystemExit(0)

ln, ls = lv
rn, rs = rv
width = max(len(ln), len(rn))
ln += (0,) * (width - len(ln))
rn += (0,) * (width - len(rn))

if rn > ln:
    print("1")
elif rn < ln:
    print("0")
else:
    # Same numeric version: treat release > pre-release.
    if ls and not rs:
        print("1")
    else:
        print("0")
PY
)"

    if [[ "$should_update" != "1" ]]; then
      log_update "skip update; remote version is not newer"
      exit 0
    fi

    git -C "$REPO_ROOT" pull --ff-only --quiet || { log_update "pull failed; skipping sync"; exit 0; }
    log_update "pull succeeded; running sync-cursor.sh"
    if [[ -x "$REPO_ROOT/scripts/sync-cursor.sh" ]]; then
      "$REPO_ROOT/scripts/sync-cursor.sh" --quiet || true
      log_update "sync-cursor.sh finished"
    else
      log_update "sync-cursor.sh not executable; skipped"
    fi
  ) &
  disown 2>/dev/null || true
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

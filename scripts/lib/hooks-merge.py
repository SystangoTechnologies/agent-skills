#!/usr/bin/env python3
"""Install or remove the agent-skills sessionStart entry in ~/.cursor/hooks.json.

Cursor supports a user-level hooks.json with the same shape as project-level
hooks.json. This script merges our entry in without disturbing unrelated
hooks and is idempotent (running install twice leaves a single entry).

Usage:
    hooks-merge.py install   --hooks-file PATH --command CMD
    hooks-merge.py uninstall --hooks-file PATH --command CMD
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path
from typing import Any


MARKER = "agent-skills"  # used to identify our entry


def load(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {"version": 1, "hooks": {}}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"[hooks-merge] ERROR: {path} is not valid JSON: {exc}", file=sys.stderr)
        sys.exit(1)
    data.setdefault("version", 1)
    data.setdefault("hooks", {})
    if not isinstance(data["hooks"], dict):
        print(f"[hooks-merge] ERROR: {path} has a non-object `hooks` field", file=sys.stderr)
        sys.exit(1)
    return data


def save(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(prefix=".hooks.", suffix=".json", dir=str(path.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(data, fh, indent=2, ensure_ascii=False)
            fh.write("\n")
        os.replace(tmp_path, path)
    except Exception:
        try:
            os.unlink(tmp_path)
        finally:
            raise


def entry_matches(entry: Any, command: str) -> bool:
    if not isinstance(entry, dict):
        return False
    cmd = entry.get("command", "")
    if cmd == command:
        return True
    # Match any entry we previously installed, even if paths shifted
    # (covers older installs that pointed at .cursor/hooks/session-start.sh).
    return (
        isinstance(cmd, str)
        and MARKER in cmd
        and (cmd.endswith("session-start.sh") or cmd.endswith("cursor-session-start.sh"))
    )


def install(hooks_file: Path, command: str) -> None:
    data = load(hooks_file)
    hooks = data["hooks"]
    session = hooks.get("sessionStart")
    if not isinstance(session, list):
        session = []
    session = [e for e in session if not entry_matches(e, command)]
    session.append({"command": command})
    hooks["sessionStart"] = session
    save(hooks_file, data)
    print(f"[hooks-merge] registered sessionStart -> {command}")


def uninstall(hooks_file: Path, command: str) -> None:
    if not hooks_file.exists():
        return
    data = load(hooks_file)
    session = data.get("hooks", {}).get("sessionStart")
    if not isinstance(session, list):
        return
    remaining = [e for e in session if not entry_matches(e, command)]
    if len(remaining) == len(session):
        return
    if remaining:
        data["hooks"]["sessionStart"] = remaining
    else:
        data["hooks"].pop("sessionStart", None)
    save(hooks_file, data)
    print(f"[hooks-merge] unregistered sessionStart -> {command}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("install", "uninstall"))
    parser.add_argument("--hooks-file", required=True, type=Path)
    parser.add_argument("--command", required=True)
    args = parser.parse_args()

    if args.action == "install":
        install(args.hooks_file, args.command)
    else:
        uninstall(args.hooks_file, args.command)
    return 0


if __name__ == "__main__":
    sys.exit(main())

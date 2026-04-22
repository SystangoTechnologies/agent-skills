# Cursor global installer

Install the agent-skills pack into `~/.cursor/` so every Cursor project on
your machine automatically loads the skills, slash commands, agent personas,
and `sessionStart` hook — the same experience as the Claude Code plugin.

The repo keeps a single canonical source for each asset type. The installer
mirrors them into the layout Cursor expects:

| Source (this repo)         | Destination (user global) |
| -------------------------- | ------------------------- |
| `skills/<name>/`           | `~/.cursor/skills/<name>/`      |
| `.claude/commands/<x>.md`  | `~/.cursor/commands/sys-<x>.md` |
| `agents/<x>.md`            | `~/.cursor/agents/<x>.md`       |
| `hooks/cursor-session-start.sh` | entry in `~/.cursor/hooks.json` |

Symlinks (not copies) are used, so `git pull` in the plugin checkout takes
effect immediately — no re-run needed.

## Install

From a local clone:

```bash
./scripts/install-cursor.sh
```

From a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/SystangoTechnologies/agent-skills/main/scripts/install-cursor.sh | bash
```

The installer:

1. Clones (or `git pull`s) the repo into `~/.cursor/plugins/agent-skills/`.
2. Symlinks skills, commands, and agents into `~/.cursor/`.
   - Commands are exposed only as `sys-` aliases (for example `/sys-spec`) so
     Cursor usage stays consistent with the `sys:*` convention in command content.
3. Merges a single `sessionStart` entry into `~/.cursor/hooks.json` (merges,
   doesn't overwrite — any existing hooks you have are preserved).

## Auto-update

`sessionStart` fires on every new agent session. The hook detaches a
background `git pull --ff-only` + `sync-cursor.sh`, throttled to once every 6 hours.
The current session starts instantly; updates land on the *next* session —
same model as the Claude plugin.

| Env var                          | Effect                                         |
| -------------------------------- | ---------------------------------------------- |
| `AGENT_SKILLS_AUTO_UPDATE=0`     | Disable background self-update                 |
| `AGENT_SKILLS_UPDATE_INTERVAL=N` | Throttle interval in seconds (default `21600`) |

To update manually at any time:

```bash
git -C ~/.cursor/plugins/agent-skills pull
~/.cursor/plugins/agent-skills/scripts/sync-cursor.sh
```

## Options

| Flag / env                        | Effect                                              |
| --------------------------------- | --------------------------------------------------- |
| `--force` / `-f`                  | Overwrite existing non-symlink entries of same name |
| `--dir=PATH` / `CURSOR_HOME=PATH` | Use a different Cursor home (default `~/.cursor`)   |
| `AGENT_SKILLS_REPO=<git url>`     | Clone from a fork/mirror                            |
| `AGENT_SKILLS_REF=<ref>` / `--ref=REF` | Install a specific branch, tag, or commit (useful for testing unmerged branches or pinning to a release) |

## Uninstall

```bash
~/.cursor/plugins/agent-skills/scripts/uninstall-cursor.sh           # unlink + detach hook
~/.cursor/plugins/agent-skills/scripts/uninstall-cursor.sh --purge   # also delete the checkout
```

Uninstall removes only symlinks that canonicalize back into the plugin
directory, so any unrelated skills/commands/hooks you have in `~/.cursor/`
are left untouched.

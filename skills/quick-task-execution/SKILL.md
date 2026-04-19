---
name: quick-task-execution
description: Executes a small, ad-hoc change with one short plan and one atomic commit — skipping the full spec → plan → build ceremony. Use when the change is narrow, single-domain, and the approach is obvious. Use when `/spec` → `/plan` → `/build` would cost more than the work itself. Do NOT use for multi-file features, new public interfaces, or work with real ambiguity.
---

# Quick Task Execution

## Overview

Quick mode keeps the discipline — plan, implement, verify, atomic commit — but drops the ceremony. One short plan file, one commit, done. It exists so small changes (a config tweak, a typo sweep, a one-file bug fix) stay tracked without being routed through `/spec` and `/plan`.

## When to Use

- A focused bug fix, config change, dependency bump, or one-file refactor
- A doc update, typo sweep, or one-off script
- A change you could fully describe in one paragraph
- The implementation path is obvious and single-domain

**When NOT to use:**

- Multi-file features touching more than one domain → `/spec` → `/plan` → `/build`
- A new public interface is introduced → use `api-and-interface-design` via `/spec`
- Real ambiguity about *what* to build → `/spec`
- Real ambiguity about *how* to build it → investigate first, then `/spec` or `/plan`

## Process

### Step 1: Write the plan

Create `specs/quick/{slug}.md` where `{slug}` is a short, lowercase, hyphen-separated phrase derived from the task (e.g. `fix-auth-redirect`, `bump-axios`). Use this template:

```markdown
# {slug}

## Goal
{One paragraph: what is changing and why.}

## Files likely touched
- {path}
- {path}

## Acceptance criteria
- [ ] {Observable, verifiable outcome}
- [ ] {Observable, verifiable outcome}

## Verification
- `npm run build`
- `npx tsc --noEmit`
- {any task-specific checks}

## Noticed but not touched
{Adjacent issues spotted during the work. Leave empty at start.}
```

Keep it to one screen. If the plan grows past a screen, the task isn't a quick task — promote it to `/spec` → `/plan`.

### Step 2: Identify the domain and load the skill

Before writing code, classify the change and load the matching domain skill:

- UI components, layouts, state → `frontend-ui-engineering`
- API endpoints, interfaces, module boundaries → `api-and-interface-design`
- Auth, input validation, PII, sessions → `security-and-hardening`
- None of the above (pure infra, config, docs) → proceed directly

State the loaded skill explicitly before writing code — e.g. *"Loading `api-and-interface-design` for this task."* If the change spans more than one domain, the task is too big for quick mode; stop and use `/plan`.

### Step 3: Implement

Apply the domain skill's patterns. Keep the codebase compilable throughout — don't leave the build broken between edits. Touch only what the goal requires.

If you spot adjacent issues, record them under *Noticed but not touched* in the plan file. Do not fix them here.

### Step 4: Verify

Run every command in the plan's *Verification* block. Re-read the diff against *Acceptance criteria* and honestly check each box.

If a check fails, fix and re-verify. If the fix would expand scope beyond the goal, stop and escalate — don't silently grow the task. On persistent failure, follow `debugging-and-error-recovery`.

### Step 5: Commit atomically

Follow the `git-workflow-and-versioning` skill. One commit, scoped to this task, with the plan file staged alongside the code change. The commit message describes the outcome; the plan file records the goal and acceptance criteria.

No separate summary file, no state table — `git log` plus `specs/quick/` is the record.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's too small to write a plan" | The plan is ~15 lines and buys you acceptance criteria, a rollback anchor, and a record in `git log`. Skipping it is how small tasks turn into untracked half-finished work. |
| "I'll just add this related fix while I'm here" | Scope creep. Log it under *Noticed but not touched* and file a new quick task. One task, one commit. |
| "I'll put this under `specs/tasks/` with the rest" | `specs/tasks/plan.md` and `todo.md` belong to planned phases. Mixing ad-hoc work there pollutes the phase record. Quick tasks live in `specs/quick/`. |
| "This is small — I can skip the domain skill" | The skill catches the category-of-bug you don't see coming. An auth tweak without `security-and-hardening` is how CSRF regressions ship. |
| "I'll skip verification, it's obviously fine" | The five-minute verify is the whole point of keeping the plan. If you're not going to run it, don't write it. |
| "Three small commits feel cleaner than one" | Quick mode is one atomic unit of work = one commit = one rollback. If it genuinely needs multiple commits, it belongs in `/build`, not `/quick`. |

## Red Flags

- Code is being written before `specs/quick/{slug}.md` exists
- The plan file grew past one screen — this isn't a quick task anymore
- Commit touches files unrelated to the goal
- Quick work written into `specs/tasks/plan.md` or `todo.md`
- Acceptance criteria boxes never got checked
- Domain skill never named before implementation started
- *Noticed but not touched* is empty after a non-trivial change — either nothing was spotted (plausible) or scope crept silently (check the diff)

## Verification

- [ ] `specs/quick/{slug}.md` exists with Goal, Files, Acceptance criteria, Verification
- [ ] All acceptance criteria are checked `[x]`
- [ ] The domain skill (if any) was named before implementation
- [ ] `npm run build` and `npx tsc --noEmit` pass (or the project-equivalent verification commands)
- [ ] Exactly one commit was created, with the plan file staged alongside the code
- [ ] No entries were added to `specs/tasks/plan.md` or `specs/tasks/todo.md`

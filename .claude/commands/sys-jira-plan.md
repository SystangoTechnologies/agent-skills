---
description: Break Jira story work into verifiable tasks using story-scoped plan files
---

Invoke the `sys:jira-planning-and-task-breakdown` skill.

Read the existing story spec (`spec/{story-id}.md`) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Planning produces **two files** for the same story ID as the spec. Write them in this order — do not interleave:

**Step A — Write `{project-root}/spec/{story-id}/tasks/plan.md` first.**
Use the *Plan Document Template* from the skill. plan.md contains the overview, architecture decisions, a compact **Task Index** (one line per task), checkpoints, risks, and open questions. No detailed task blocks in this file.

**Step B — Re-read `{project-root}/spec/{story-id}/tasks/plan.md` before writing todo.md.**
This is required, not optional. Reading plan.md back grounds the next step in the index you just wrote and refreshes context on the task ordering. Also re-anchor on the per-task template and the *todo.md Template* in the skill's Step 4.

**Step C — Write `{project-root}/spec/{story-id}/tasks/todo.md`.**
For every task in plan.md's Task Index, write the **full detailed task block** per the per-task template — acceptance criteria, Unit Tests (deferred), verification, dependencies, files, scope, domain skill. No simplified bullets, no abbreviated entries. The order of tasks in todo.md must match plan.md's Task Index exactly.

Before finishing, run the Step 5 validation checklist from the skill against todo.md.

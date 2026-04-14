---
description: Implement the next task incrementally — build, verify, commit at the end
---

Invoke the agent-skills:incremental-implementation skill.

Pick the next unchecked task from `specs/tasks/todo.md`. For each task:

1. **Read the task** — description, acceptance criteria, dependencies, files likely touched
2. **Identify the domain** — UI components → `frontend-ui-engineering`; API/interfaces/types → `api-and-interface-design`; auth/input/PII → `security-and-hardening`
3. **Load the domain skill** — invoke the relevant skill and apply its patterns before writing code
4. **Implement** the task incrementally (one logical slice at a time)
5. **Verify** — run `npm run build` and `npx tsc --noEmit` to confirm compilation
6. **Update todo** — mark the task `[x]` in `specs/tasks/todo.md`
7. **Repeat** for the next unchecked task

Do not write tests during implementation. Do not commit after each task.

After ALL tasks are complete (or at end of session): commit all completed work once using the `git-workflow-and-versioning` skill.

If any step fails, follow the `agent-skills:debugging-and-error-recovery` skill.

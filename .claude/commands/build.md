---
description: Implement the next task incrementally — build, verify
---

Invoke the agent-skills:incremental-implementation skill.

Pick the next pending task from the plan. For each task:

1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Implement the incremental code
4. Run the build to verify compilation
5. Mark the task complete and move to the next one

If any step fails, follow the agent-skills:debugging-and-error-recovery skill.

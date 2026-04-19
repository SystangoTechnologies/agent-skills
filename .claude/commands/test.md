---
description: Write unit tests for implemented tasks — reads deferred test notes from todo.md and generates comprehensive test coverage
---

Invoke the sys:generate-unit-tests skill.

Pick the next task in `specs/tasks/todo.md` whose **Unit Tests (deferred)** section has an unchecked `- [ ] Tests written` checkbox. For each task:

1. **Read the deferred section** — functions/behaviors to cover, edge cases, test type, suggested file path
2. **Analyze source files** listed in the task — understand signatures, side effects, dependencies, and error paths
3. **Select framework** — check `package.json` for Jest/Vitest (JS/TS), pytest (Python), or equivalent; load `references/testing-patterns.md`
4. **Write tests** at the suggested file path: happy path + edge cases + error conditions + boundary values; mock only at system boundaries; use Arrange-Act-Assert
5. **Run tests** — `npm test` must pass before proceeding; do not fix source code if bugs are found — surface them instead
6. **Mark complete** — check `- [x] Tests written` in the task's Unit Tests section in `todo.md`
7. **Repeat** for the next unchecked task

Do not modify source files. Do not commit after each task.

After ALL tasks are done (or at end of session): commit all test files once using the `git-workflow-and-versioning` skill.

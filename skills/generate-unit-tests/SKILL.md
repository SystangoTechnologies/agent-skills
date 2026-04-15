---
name: generate-unit-tests
description: Generates unit tests for already-implemented features by reading deferred test notes from the task list and analyzing source code. Use after the build phase when tasks in specs/tasks/todo.md have an unchecked "Tests written" checkbox. Use when running /test to execute the test phase.
---

# Generate Unit Tests

## Overview

Read the deferred test notes written during planning, analyze the corresponding source code, write comprehensive tests, and verify they pass. This skill executes the test phase that the build phase explicitly skips — converting `**Unit Tests (deferred):**` sections in `specs/tasks/todo.md` into real, passing test files covering happy paths, edge cases, and error conditions.

## When to Use

- After running `/build` on one or more tasks
- Any task in `specs/tasks/todo.md` has an unchecked `- [ ] Tests written` checkbox
- You want to close the test gap before code review or shipping

**When NOT to use:** During the build phase — that separation is intentional. Do not mix test writing with feature implementation.

## The Test Generation Cycle

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│   Read task's Unit Tests (deferred) section  ──→     │
│   Analyze source files listed in task        ──→     │
│   Select framework + load testing patterns   ──→     │
│   Generate: happy path + edge cases +        ──→     │
│             error conditions + setup/teardown        │
│   Run npm test ──→ All pass?                 ──→     │
│   Check [x] Tests written in todo.md         ──→     │
│   Next task                                          │
│                                                      │
│   (After ALL tasks done)                             │
│   Commit all test files once                         │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## The Testing Process

### Pre-Condition: Verify Build Phase is Complete

Before writing any tests, check:

- [ ] All build tasks in `specs/tasks/todo.md` are marked `[x]` (outer task checkbox)
- [ ] No task's `Unit Tests (deferred)` checkbox is already checked `[x]` (would indicate tests were written during build — a violation)
- [ ] `npm run build` or equivalent build command succeeds

**If you find test files already created during the build phase:** Flag this to the user as a process violation. The build phase must not create test files — that is the test phase's responsibility.

### Step 1: Find Tasks Needing Tests

Open `specs/tasks/todo.md`. Find tasks where the Unit Tests (deferred) section has an unchecked `Tests written` checkbox:

```markdown
**Unit Tests (deferred):**
- [ ] Tests written          ← unchecked = needs tests
- Functions/behaviors to cover: createTask, validateInput
- Edge cases: empty title, duplicate ID
- Test type: unit
- Suggested file: `tests/services/task-service.test.ts`
```

Process tasks in top-to-bottom order. Skip tasks where `- [x] Tests written` is already checked.

### Step 2: Analyze the Source Code

Before writing any test, read the source files listed in the task's "Files likely touched". Understand:

- Function signatures and return types
- Side effects (DB calls, API calls, file I/O, events emitted)
- External dependencies that need mocking
- Error paths and thrown exceptions

This analysis — not just the deferred notes — determines what tests to write.

### Step 3: Select Framework and Load Patterns

Choose the test framework based on the project's existing setup:

| Language / stack | Framework |
|---|---|
| TypeScript / JavaScript (Node) | Jest or Vitest (check `package.json`) |
| React components | Jest + React Testing Library |
| Python | pytest or unittest |
| Java / Kotlin | JUnit or TestNG |
| Go | Go testing package |
| Ruby | RSpec or Minitest |

Load `references/testing-patterns.md` for the appropriate patterns (Arrange-Act-Assert, mocking, React Testing Library, Supertest, Playwright).

### Step 4: Write the Tests

Use the suggested file path from the task. If the file already exists, add to it rather than replacing.

**Every test suite must cover:**

1. **Happy path** — the normal, expected behavior works as specified
2. **Edge cases** — all cases listed in the deferred section, plus any you identified in source analysis
3. **Error conditions** — invalid input, missing data, failed dependencies
4. **Boundary conditions** — empty arrays, null/undefined, zero values, max lengths

**Test structure rules:**
- Use Arrange-Act-Assert for every test
- One concept per test — split compound assertions into separate tests
- Name tests descriptively: `[unit] [expected behavior] [condition]`
- DAMP over DRY — each test should be self-contained and readable without tracing helpers
- Assert on outcomes (state), not on which internal methods were called (interactions)

**Mocking rules:**
- Mock only at system boundaries: DB calls, HTTP requests, file system, external APIs, time/randomness
- Do NOT mock internal utility functions, pure functions, or business logic
- Prefer real implementations > in-memory fakes > stubs > interaction mocks

```typescript
// Good: mocks only the DB boundary
jest.mock('./db', () => ({
  tasks: { insert: jest.fn().mockResolvedValue({ id: '1' }) }
}));

// Bad: mocks an internal helper
jest.mock('./utils/validate', () => ({ validateTitle: jest.fn() }));
```

**Import and scaffold:**

Emit complete test files with:
- All necessary imports
- Mock declarations at the top
- `describe` blocks grouping related tests
- `beforeEach` / `afterEach` for setup and teardown
- Individual `it` / `test` blocks using Arrange-Act-Assert

### Step 5: Run the Tests

```bash
npm test
```

All tests must pass before proceeding. If a test fails:

1. Read the failure output carefully
2. Determine: is the test wrong, or did you find an implementation bug?
3. Fix the test assertion if it was incorrect
4. If you found an implementation bug: note it and surface it to the user — do not fix source code during the test phase
5. Do not mark `Tests written` until all tests are green

### Step 6: Mark the Task Complete

After tests pass, update the task in `specs/tasks/todo.md`:

```markdown
**Unit Tests (deferred):**
- [x] Tests written          ← check this after tests pass
- Functions/behaviors to cover: createTask, validateInput
...
```

Do NOT touch the outer task checkbox `- [ ] Task N` — that belongs to the build phase. Only the `Tests written` checkbox is yours to check.

### Step 7: Repeat and Commit

Move to the next task with an unchecked `Tests written` checkbox. Do not commit between tasks.

After all tasks are processed (or at session end):

1. Verify `npm test` passes with no failures or skipped tests
2. Confirm all processed tasks have `- [x] Tests written` in `todo.md`
3. Follow the `git-workflow-and-versioning` skill to create a single atomic commit
4. Write the commit message to describe what was tested, not individual task numbers

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The deferred section is vague, I'll skip this task" | The notes are a starting point. Read the source code — it tells you everything the tests need to cover. |
| "The implementation is simple, tests aren't needed" | Simple functions are the easiest to test and the most often broken by adjacent changes. Write the tests. |
| "I'll run all tests at the end" | Run `npm test` after each task. A failure caught per-task is a 2-minute fix; caught at the end, it's a debugging session. |
| "The build phase verified the feature works" | Build verification checks compilation only. Tests check behavior. They are not the same thing. |
| "I found a bug — I'll fix the source code quickly" | Note it and surface it. Fixing source during the test phase mixes concerns and can introduce new failures. |
| "I should write the test first (TDD-style)" | This skill is post-implementation by design. The deferred section already captured the intent — your job is to generate tests that verify the existing code against that intent. |

## Red Flags

- Marking `[x] Tests written` before `npm test` passes
- Tests that only assert a function was called (not what it returned)
- Mocking business logic or internal helpers instead of system boundaries
- No edge case or error condition tests despite the deferred section listing them
- Modifying source files during the test phase
- Committing after each task instead of once at the end
- Skipping tasks because the deferred section "looks covered already"
- All tests in one giant `describe` block with no grouping

## Verification

After all tasks in the session are done:

- [ ] `npm test` passes with zero failures and zero skipped tests
- [ ] Every processed task has `- [x] Tests written` in `todo.md`
- [ ] Test files exist at the paths noted in each task's deferred section
- [ ] Happy path, edge cases, and error conditions are covered per task
- [ ] No source files were modified during this phase
- [ ] All test files are committed in a single cohesive commit

---
name: planning-and-task-breakdown
description: Breaks work into ordered tasks. Use when you have a spec or clear requirements and need to break work into implementable tasks. Use when a task feels too large to start, when you need to estimate scope, or when parallel work is possible.
---

# Planning and Task Breakdown

## Overview

Decompose work into small, verifiable tasks with explicit acceptance criteria. Good task breakdown is the difference between an agent that completes work reliably and one that produces a tangled mess. Every task should be small enough to implement, test, and verify in a single focused session.

## When to Use

- You have a spec and need to break it into implementable units
- A task feels too large or vague to start
- Work needs to be parallelized across multiple agents or sessions
- You need to communicate scope to a human
- The implementation order isn't obvious

**When NOT to use:** Single-file changes with obvious scope, or when the spec already contains well-defined tasks.

## The Planning Process

### Step 1: Enter Plan Mode

Before writing any code, operate in read-only mode:

- Read `.context/project.md` and `.context/architecture.md` for system context
- Read `.context/conventions.md` to identify existing patterns and standards to follow
- Read `.context/concerns.md` to surface risks and unknowns before the plan is written
- Read the spec and relevant codebase sections
- Map dependencies between components

**Do NOT write code during planning.** The output is a plan document, not implementation.

### Step 2: Identify the Dependency Graph

Map what depends on what:

```
Database schema
    │
    ├── API models/types
    │       │
    │       ├── API endpoints
    │       │       │
    │       │       └── Frontend API client
    │       │               │
    │       │               └── UI components
    │       │
    │       └── Validation logic
    │
    └── Seed data / migrations
```

Implementation order follows the dependency graph bottom-up: build foundations first.

### Step 3: Slice Vertically

Instead of building all the database, then all the API, then all the UI — build one complete feature path at a time:

**Bad (horizontal slicing):**
```
Task 1: Build entire database schema
Task 2: Build all API endpoints
Task 3: Build all UI components
Task 4: Connect everything
```

**Good (vertical slicing):**
```
Task 1: User can create an account (schema + API + UI for registration)
Task 2: User can log in (auth schema + API + UI for login)
Task 3: User can create a task (task schema + API + UI for creation)
Task 4: User can view task list (query + API + UI for list view)
```

Each vertical slice delivers working, testable functionality.

### Step 4: Write Tasks

Planning produces **two documents**, not one:

- **`specs/tasks/plan.md`** — the high-level plan. Contains the overview, architecture decisions, a compact **Task Index** (one line per task), checkpoints, risks, and open questions. See the *Plan Document Template* below.
- **`specs/tasks/todo.md`** — the detailed task list. Contains the **full per-task block** (template below) for every task in the index, stacked in order. See the *todo.md Template* below.

Think of plan.md as the table of contents and todo.md as the chapters. Every task in plan.md's Task Index must have a matching detailed entry in todo.md.

Each task in **todo.md** follows this structure:

```markdown
## Task [N]: [Short descriptive title]

**Description:** One paragraph explaining what this task accomplishes.

**Acceptance criteria:**
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]

**Unit Tests (deferred):**
- [ ] Tests written
- Functions/behaviors to cover: [e.g. createTask, validateInput]
- Edge cases: [e.g. empty title, duplicate ID, missing required field]
- Test type: [unit | component | end-to-end]
- Suggested file: `tests/path/to/feature.test.ts`

**Verification:**
- [ ] Build succeeds: `npm run build`
- [ ] Type checking passes: `npx tsc --noEmit`
- [ ] Manual check: [description of what to verify]

**Dependencies:** [Task numbers this depends on, or "None"]

**Files likely touched:**
- `src/path/to/file.ts`

**Estimated scope:** [Small: 1-2 files | Medium: 3-5 files | Large: 5+ files]

**Domain skill:** [`api-and-interface-design` | `frontend-ui-engineering` | `security-and-hardening` | None]
```

**Field-by-field rules:**

- **Acceptance criteria** — every item must use checkbox syntax (`- [ ]`), not plain bullets (`- `). Plain bullets are not trackable.
- **Unit Tests (deferred)** — required for every task. The `- [ ] Tests written` line must use checkbox syntax (`- [ ]`), not a plain bullet. This checkbox is the contract between the planning and testing phases — the `/test` phase checks it after writing tests. The build phase skips this section entirely and does not create test files.
- **Verification** — every item must use checkbox syntax (`- [ ]`), not plain bullets. Build-phase gates verify compilation and runtime only — never `npm test`, `pnpm test`, or coverage thresholds.
- **Domain skill** — required for every task. The planner knows the task's domain when writing it. Embed the classification so the builder doesn't have to re-derive it. Use `None` for pure infrastructure tasks (build config, utility functions, migrations with no auth surface). Tasks involving REST endpoints, HTTP status codes, request/response contracts, or middleware must specify `api-and-interface-design`. Tasks involving UI components, layouts, or state must specify `frontend-ui-engineering`. Tasks involving auth, validation, PII, or sessions must specify `security-and-hardening`. A task may list more than one skill if it spans domains.

#### todo.md Template

`todo.md` is a flat stack of detailed task blocks — no extra prose, no simplified bullets. Every task from plan.md's Task Index appears here in full form, in the same order:

```markdown
# Task List: [Feature/Project Name]

Detailed tasks for the plan in `plan.md`. Build one task at a time, top to bottom.

---

## Task 1: [Short descriptive title]

**Description:** One paragraph explaining what this task accomplishes.

**Acceptance criteria:**
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]

**Unit Tests (deferred):**
- [ ] Tests written
- Functions/behaviors to cover: [e.g. createTask, validateInput]
- Edge cases: [e.g. empty title, duplicate ID, missing required field]
- Test type: [unit | component | end-to-end]
- Suggested file: `tests/path/to/feature.test.ts`

**Verification:**
- [ ] Build succeeds: `npm run build`
- [ ] Type checking passes: `npx tsc --noEmit`
- [ ] Manual check: [description of what to verify]

**Dependencies:** None

**Files likely touched:**
- `src/path/to/file.ts`

**Estimated scope:** Small: 1-2 files

**Domain skill:** None

---

## Task 2: [Short descriptive title]

**Description:** ...

**Acceptance criteria:**
- [ ] ...

**Unit Tests (deferred):**
- [ ] Tests written
- Functions/behaviors to cover: ...
- Edge cases: ...
- Test type: unit
- Suggested file: `tests/path/to/feature.test.ts`

**Verification:**
- [ ] Build succeeds: `npm run build`
- [ ] Type checking passes: `npx tsc --noEmit`
- [ ] Manual check: ...

**Dependencies:** Task 1

**Files likely touched:**
- `src/path/to/file.ts`

**Estimated scope:** Medium: 3-5 files

**Domain skill:** api-and-interface-design

---

## Checkpoint: After Tasks 1-2
- [ ] Build passes
- [ ] Core flow works end-to-end

---

## Task 3: ...
```

Every task block must include all fields from the per-task template above. Do not abbreviate, do not use simplified bullets, do not omit the Unit Tests (deferred) section. If you find yourself shortening a task block to save space, stop — either the task belongs in the Task Index only (plan.md) or it needs its full detail here.

### Step 5: Validate Task List Structure

Before advancing to the build phase, run this checklist against every task in the list. If any item fails, fix the task before proceeding — do not defer fixes to the build phase.

**Phase separation:**
- [ ] Every task has a `Unit Tests (deferred)` section with `- [ ] Tests written` using checkbox syntax (`- [ ]`), not a plain bullet (`- `)
- [ ] No task's primary deliverable is a test file — test files are created in the `/test` phase, not as build tasks. This includes tasks titled "Test Suite", "Write Tests", etc. — if its purpose is producing test files, it should not exist as a task
- [ ] No task description mentions creating test files, placeholder tests, or dummy test files during the build phase
- [ ] No gate or verification step requires `npm test`, `pnpm test`, `--listTests`, or coverage thresholds — build gates verify compilation and runtime only

**Template compliance:**
- [ ] Every acceptance criterion uses checkbox format (`- [ ]`), not plain bullets (`- `)
- [ ] Every verification step uses checkbox format (`- [ ]`), not plain bullets (`- `)
- [ ] Every task that involves API, UI, or security work has a `**Domain skill:**` field identifying which skill to load before implementation. Tasks with REST endpoints, HTTP status codes, request/response contracts, or middleware must specify `api-and-interface-design`. Pure infrastructure tasks use `None`

**File location:**
- [ ] Task list is saved to `specs/tasks/todo.md`

### Step 6: Order and Checkpoint

Arrange tasks so that:

1. Dependencies are satisfied (build foundation first)
2. Each task leaves the system in a working state
3. Verification checkpoints occur after every 2-3 tasks
4. High-risk tasks are early (fail fast)

Add explicit checkpoints:

```markdown
## Checkpoint: After Tasks 1-3
- [ ] All tests pass
- [ ] Application builds without errors
- [ ] Core user flow works end-to-end
- [ ] Review with human before proceeding
```

## Task Sizing Guidelines

| Size | Files | Scope | Example |
|------|-------|-------|---------|
| **XS** | 1 | Single function or config change | Add a validation rule |
| **S** | 1-2 | One component or endpoint | Add a new API endpoint |
| **M** | 3-5 | One feature slice | User registration flow |
| **L** | 5-8 | Multi-component feature | Search with filtering and pagination |
| **XL** | 8+ | **Too large — break it down further** | — |

If a task is L or larger, it should be broken into smaller tasks. An agent performs best on S and M tasks.

**When to break a task down further:**
- It would take more than one focused session (roughly 2+ hours of agent work)
- You cannot describe the acceptance criteria in 3 or fewer bullet points
- It touches two or more independent subsystems (e.g., auth and billing)
- You find yourself writing "and" in the task title (a sign it is two tasks)

## Plan Document Template

This is the template for **plan.md only**. The Task Index below is a compact reference — one line per task. The full detailed task blocks go in **todo.md** (see the *todo.md Template* in Step 4).

```markdown
# Implementation Plan: [Feature/Project Name]

## Overview
[One paragraph summary of what we're building]

## Architecture Decisions
- [Key decision 1 and rationale]
- [Key decision 2 and rationale]

## Task Index

Compact index of tasks. Full detail for each task lives in `todo.md`.

### Phase 1: Foundation
- [ ] Task 1: ...
- [ ] Task 2: ...

### Checkpoint: Foundation
- [ ] Tests pass, builds clean

### Phase 2: Core Features
- [ ] Task 3: ...
- [ ] Task 4: ...

### Checkpoint: Core Features
- [ ] End-to-end flow works

### Phase 3: Polish
- [ ] Task 5: ...
- [ ] Task 6: ...

### Checkpoint: Complete
- [ ] All acceptance criteria met
- [ ] Ready for review

## Risks and Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk] | [High/Med/Low] | [Strategy] |

## Open Questions
- [Question needing human input]
```

## Parallelization Opportunities

When multiple agents or sessions are available:

- **Safe to parallelize:** Independent feature slices, tests for already-implemented features, documentation
- **Must be sequential:** Database migrations, shared state changes, dependency chains
- **Needs coordination:** Features that share an API contract (define the contract first, then parallelize)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll figure it out as I go" | That's how you end up with a tangled mess and rework. 10 minutes of planning saves hours. |
| "The tasks are obvious" | Write them down anyway. Explicit tasks surface hidden dependencies and forgotten edge cases. |
| "Planning is overhead" | Planning is the task. Implementation without a plan is just typing. |
| "I can hold it all in my head" | Context windows are finite. Written plans survive session boundaries and compaction. |
| "I'll make the tests a separate task" | Tests belong in the `/test` phase. Each task's `Unit Tests (deferred)` section captures what to test. Creating a test task defeats phase separation and forces tests to be written during build. Don't do this. |

## Red Flags

- Starting implementation without a written task list
- Tasks that say "implement the feature" without acceptance criteria
- No verification steps in the plan
- Unit Tests (deferred) section missing from a task (every task needs test notes, even if deferred)
- `Tests written` line using a plain bullet (`- Tests written`) instead of checkbox syntax (`- [ ] Tests written`) — the checkbox is the contract between planning and testing phases
- Acceptance criteria or verification steps using plain bullets instead of checkbox syntax — plain bullets are not trackable
- Task whose primary deliverable is a test file — tests are a phase, not a task. Document them in `Unit Tests (deferred)`, don't build them as tasks
- Task description mentioning "create test files", "placeholder tests", or "dummy test files" — no test files are created during build
- Gate or verification step that requires `npm test`, `pnpm test`, `--listTests`, or coverage thresholds — build gates verify compilation and runtime, not test coverage
- API/UI/security task missing a `Domain skill` field — the planner knows the domain; don't make the builder guess
- All tasks are XL-sized
- No checkpoints between tasks
- Dependency order isn't considered

## Verification

Before starting implementation, confirm:

- [ ] Every task has acceptance criteria using checkbox syntax (`- [ ]`)
- [ ] Every task has verification steps using checkbox syntax (`- [ ]`)
- [ ] Every task has a Unit Tests (deferred) section with `- [ ] Tests written` (checkbox, not plain bullet) and at least one behavior listed
- [ ] Every task has a `**Domain skill:**` field (`api-and-interface-design`, `frontend-ui-engineering`, `security-and-hardening`, or `None`)
- [ ] No task's primary deliverable is a test file
- [ ] No gate requires `npm test`, `pnpm test`, or coverage thresholds
- [ ] Task dependencies are identified and ordered correctly
- [ ] No task touches more than ~5 files
- [ ] Checkpoints exist between major phases
- [ ] The human has reviewed and approved the plan

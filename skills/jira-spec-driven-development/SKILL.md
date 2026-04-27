---
name: jira-spec-driven-development
description: Creates specs before coding with mandatory Jira MCP validation and story-key grounding. Use when starting a Jira-tracked feature or significant change and requirements are unclear, ambiguous, or incomplete.
---

# Jira Spec-Driven Development

## Overview

Write a structured specification before writing any code. This is the same spec-first discipline as `spec-driven-development`, with one mandatory addition: validate Jira MCP connectivity and anchor the spec to a Jira story/task key.

The spec is the shared source of truth between you and the human engineer - it defines what we're building, why, and how we'll know it's done. Code without a spec is guessing.

## When to Use

- Starting a new Jira-tracked project or feature
- Requirements are ambiguous or incomplete
- The change touches multiple files or modules
- You're about to make an architectural decision
- The task would take more than 30 minutes to implement

**When NOT to use:** Single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained.

## The Gated Workflow

Jira spec-driven development has four phases. Do not advance to the next phase until the current one is validated.

```
SPECIFY ──→ PLAN ──→ TASKS ──→ IMPLEMENT
   │          │        │          │
   ▼          ▼        ▼          ▼
 Human      Human    Human      Human
 reviews    reviews  reviews    reviews
```

### Phase 1: Specify

Start with a high-level vision. Ask the human clarifying questions until requirements are concrete.

**Mandatory Jira pre-check.** Before listing assumptions or writing spec content:

1. Verify Jira MCP connection is available and usable.
2. If Jira MCP is unavailable, stop and ask the user to connect/authenticate.
3. Capture Jira story input:
   - Preferred: story key (for example, `VS-10`)
   - Fallback: user-provided story/task details
4. If a key is provided and Jira is connected, fetch story context first and use it as baseline requirements.
5. Inspect the story/ticket description for related Jira ticket mentions (for example, `VS-11`, `PROJ-245`).
6. If related tickets are found and accessible, fetch their context too and merge only relevant details into the baseline requirements.
7. Ask the user: "Would you also like to pull any additional context?" and incorporate provided context if relevant.
8. Scope guard: do not create specs for related/dependency tickets; create a spec only for the current ticket the user wants to achieve.

**Ground yourself in project context first.** If `.context/` files exist (from brownfield-discovery), read them before listing assumptions:
- `.context/project.md` - project purpose, users, non-goals
- `.context/stack.md` - tech stack, dependencies, environment
- `.context/architecture.md` - existing design decisions and constraints
- `.context/conventions.md` - coding standards, gotchas
- `.context/concerns.md` - known risks and technical debt

This replaces guessing with known facts.

**Surface assumptions immediately.** Before writing any spec content, list what you're assuming:

```
ASSUMPTIONS I'M MAKING:
1. This is a web application (not native mobile)
2. Authentication uses session-based cookies (not JWT)
3. The database is PostgreSQL (based on existing Prisma schema)
4. We're targeting modern browsers only (no IE11)
→ Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The spec's entire purpose is to surface misunderstandings *before* code gets written - assumptions are the most dangerous form of misunderstanding.

**Write a spec document covering these six core areas:**

1. **Objective** - What are we building and why? Who is the user? What does success look like?

2. **Commands** - Full executable commands with flags, not just tool names.
   ```
   Build: npm run build
   Test: npm test -- --coverage
   Lint: npm run lint --fix
   Dev: npm run dev
   ```

3. **Project Structure** - Where source code lives, where tests go, where docs belong.
   ```
   src/           → Application source code
   src/components → React components
   src/lib        → Shared utilities
   tests/         → Unit tests
   e2e/           → End-to-end tests
   docs/          → Documentation
   ```

4. **Code Style** - One real code snippet showing your style beats three paragraphs describing it. Include naming conventions, formatting rules, and examples of good output.

5. **Testing Strategy** - What framework, where tests live, coverage expectations, which test levels for which concerns.

6. **Boundaries** - Three-tier system:
   - **Always do:** Run tests before commits, follow naming conventions, validate inputs
   - **Ask first:** Database schema changes, adding dependencies, changing CI config
   - **Never do:** Commit secrets, edit vendor directories, remove failing tests without approval

**Spec template:**

```markdown
# Spec: [{story-id}] [Project/Feature Name]

## Objective
[What we're building and why. User stories or acceptance criteria.]

## Tech Stack
[Framework, language, key dependencies with versions]

## Commands
[Build, test, lint, dev — full commands]

## Project Structure
[Directory layout with descriptions]

## Code Style
[Example snippet + key conventions]

## Testing Strategy
[Framework, test locations, coverage requirements, test levels]

## Boundaries
- Always: [...]
- Ask first: [...]
- Never: [...]

## Success Criteria
[How we'll know this is done — specific, testable conditions]

## Open Questions
[Anything unresolved that needs human input]
```

**Storage rule:** Save the spec to `jira-spec/{story-id}/spec-{story-id}.md` (example: `jira-spec/VS-10/spec-VS-10.md`).

**Reframe instructions as success criteria.** When receiving vague requirements, translate them into concrete conditions:

```
REQUIREMENT: "Make the dashboard faster"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s on 4G connection
- Initial data load completes in < 500ms
- No layout shift during load (CLS < 0.1)
→ Are these the right targets?
```

This lets you loop, retry, and problem-solve toward a clear goal rather than guessing what "faster" means.

### Phase 2: Plan

With the validated spec, generate a technical implementation plan:

1. Identify the major components and their dependencies
2. Determine the implementation order (what must be built first)
3. Note risks and mitigation strategies
4. Identify what can be built in parallel vs. what must be sequential
5. Define verification checkpoints between phases

The plan should be reviewable: the human should be able to read it and say "yes, that's the right approach" or "no, change X."

### Phase 3: Tasks

Break the plan into discrete, implementable tasks:

- Each task should be completable in a single focused session
- Each task has explicit acceptance criteria
- Each task includes a verification step (test, build, manual check)
- Tasks are ordered by dependency, not by perceived importance
- No task should require changing more than ~5 files

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm — test command, build, manual check]
  - Files: [Which files will be touched]
```

### Phase 4: Implement

Execute tasks one at a time following `incremental-implementation` and `test-driven-development` skills. Use `context-engineering` to load the right spec sections and source files at each step rather than flooding the agent with the entire spec.

## Keeping the Spec Alive

The spec is a living document, not a one-time artifact:

- **Update when decisions change** - If you discover the data model needs to change, update the spec first, then implement.
- **Update when scope changes** - Features added or cut should be reflected in the spec.
- **Commit the spec** - The spec belongs in version control alongside the code.
- **Reference the spec in PRs** - Link back to the spec section that each PR implements.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This is simple, I don't need a spec" | Simple tasks don't need *long* specs, but they still need acceptance criteria. A two-line spec is fine. |
| "I'll write the spec after I code it" | That's documentation, not specification. The spec's value is in forcing clarity *before* code. |
| "The spec will slow us down" | A 15-minute spec prevents hours of rework. Waterfall in 15 minutes beats debugging in 15 hours. |
| "Requirements will change anyway" | That's why the spec is a living document. An outdated spec is still better than no spec. |
| "The user knows what they want" | Even clear requests have implicit assumptions. The spec surfaces those assumptions. |
| "I'll skip Jira for now and map it later" | Jira context is mandatory in this skill; skipping it breaks traceability and creates requirement drift. |
| "I can ignore related tickets mentioned in description" | Related tickets often carry hidden dependencies or constraints; skipping them creates incomplete specs. |
| "I'll create specs for every dependency ticket while I'm here" | Dependency tickets provide context; spec creation remains focused on the single ticket the user requested. |

## Red Flags

- Starting to write code without any written requirements
- Asking "should I just start building?" before clarifying what "done" means
- Implementing features not mentioned in any spec or task list
- Making architectural decisions without documenting them
- Skipping the spec because "it's obvious what to build"
- Writing the spec without checking Jira MCP connectivity
- Ignoring related ticket keys explicitly mentioned in the story/ticket description
- Creating specs for dependency tickets instead of focusing on the current requested ticket
- Saving the Jira spec outside `jira-spec/{story-id}/spec-{story-id}.md`

## Verification

Before proceeding to implementation, confirm:

- [ ] Jira MCP connectivity was checked before spec authoring
- [ ] Jira story key (or explicit fallback identifier) is confirmed
- [ ] Related ticket mentions in the story/ticket description were checked; relevant context was included when available
- [ ] User was asked whether to pull additional context; provided context was incorporated when relevant
- [ ] No specs were created for dependency/related tickets
- [ ] The spec covers all six core areas
- [ ] The human has reviewed and approved the spec
- [ ] Success criteria are specific and testable
- [ ] Boundaries (Always/Ask First/Never) are defined
- [ ] The spec is saved at `jira-spec/{story-id}/spec-{story-id}.md`

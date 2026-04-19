---
name: brownfield-discovery
description: Maps an existing codebase systematically. Use when entering an unfamiliar project, before writing specs or plans, or when you need to understand tech stack, architecture, conventions, business context, and outstanding concerns. Use when NOT: starting a greenfield project — you already understand the architecture.
---

# Brownfield Discovery

## Overview

When you land in an unfamiliar codebase, you need to understand *what this thing does*, *how it's built*, *how it's organized*, and *what hurts*. Brownfield discovery is the process of systematically mapping that knowledge so you can make informed decisions instead of guessing. Five parallel agents, each focused on one dimension, produce a persistent `.context/` directory that seeds all subsequent skills with the facts they need.

## When to Use

- Entering a project for the first time (existing codebase, no context docs)
- Starting work on a legacy system where you don't know the internals
- Context has drifted or been lost (team changed, documentation deleted, new environment)
- Before writing a spec for changes to an unfamiliar system
- Before planning work in an unknown codebase
- When onboarding a new agent to the project (discovery output lives across sessions)

## When NOT to Use

- Starting a greenfield project from scratch (no existing code to map)
- You already have `.context/` files and they're current (skip directly to the skill using them)
- The codebase is tiny (one file) — reading it directly is faster

## Process

### Step 1: Decide Scope

Explicitly choose: are you mapping the entire project, or one module/service?

**Full project:** Use for understanding the whole system before major changes or planning.

**Single module:** Use when you're only touching one part and need to understand it deeply without context flooding.

State the scope clearly before proceeding. This shapes which files each agent reads.

### Step 2: Spawn 5 Parallel Agents

Deploy 5 parallel Explore agents. Each gets one brief and writes **exactly one file** to `.context/`, returning only a one-sentence confirmation (no summaries, no intermediate reports back).

| Agent | Reads | Writes | Example Brief |
|-------|-------|--------|---|
| **Project** | README, PRD, docs, high-level comments, git history (project goals) | `.context/project.md` | "What does this project do? Who uses it? What problems does it solve? What are explicit non-goals?" |
| **Stack** | package.json, pyproject.toml, Gemfile, go.mod, Dockerfile, CI (yml), .env.example | `.context/stack.md` | "What's the tech stack? List all major dependencies, runtime versions, build/test/run commands. What's the deployment target?" |
| **Architecture** | Directory structure, main routers/handlers, service boundaries, data models, config files | `.context/architecture.md` | "How is the code organized? What are the major layers (frontend/backend/db)? How do components communicate? What are the integration points?" |
| **Conventions** | Actual code samples (multiple files), linter config (.eslintrc, prettier, black.toml), test examples, PR template | `.context/conventions.md` | "What are the code style rules? Naming patterns? Where do tests live? Testing approach (unit/integration/e2e)? Any project-specific gotchas?" |
| **Concerns** | TODOs in code, failing tests, bug reports, CHANGELOG, inconsistent patterns, performance notes, type errors, security comments | `.context/concerns.md` | "What's broken or fragile? What tech debt exists? Which modules are inconsistent? What areas are high-risk? What tests fail?" |

Each agent:
- Reads only the files in its category (not the full codebase)
- Writes directly to its `.context/` file (creates the directory if needed)
- Returns a one-sentence confirmation like: "✓ Stack mapped: Node 20, React 18, PostgreSQL, Vitest"

### Step 3: Synthesize into OVERVIEW.md

Read all 5 files you just created. Write `.context/OVERVIEW.md`:

```markdown
# Project Context Overview

## What This Is
[3-5 bullet summary of what the project does, who uses it, what problem it solves]

## Quick Reference

| Dimension | File | Purpose |
|-----------|------|---------|
| Project | [project.md](./project.md) | Business context: purpose, users, goals |
| Stack | [stack.md](./stack.md) | Tech: dependencies, runtime, build/test/run commands |
| Architecture | [architecture.md](./architecture.md) | Code organization: layers, boundaries, data flow |
| Conventions | [conventions.md](./conventions.md) | Code style: naming, patterns, testing approach |
| Concerns | [concerns.md](./concerns.md) | Pain points: debt, fragile areas, known issues |

## Start Here (for agents)
When you land in this project:
1. Read this overview first (you're reading it now)
2. Based on your task, jump to the relevant dimension file above
3. If writing a spec: read project.md → stack.md → architecture.md → concerns.md
4. If implementing: read conventions.md → concerns.md → architecture.md
5. If debugging: read architecture.md → stack.md → concerns.md

## Latest Update
[Date]. Checked against actual code: [3 spot-check claims verified].
```

This synthesized file is what agents read first when entering the project. Everything else is detail.

### Step 4: Update CLAUDE.md

Using the discovered facts, create or update `CLAUDE.md` at the project root. Include:

**Tech Stack** — From `stack.md`:
```markdown
## Tech Stack
- Language/Framework: [from stack.md]
- Dependencies: [key ones from stack.md]
- Database: [from stack.md]
- Build tool: [from stack.md]
- Test framework: [from stack.md]

[Link to .context/stack.md for full details]
```

**Commands** — From `stack.md`:
```markdown
## Commands
| Command | Purpose |
|---------|---------|
| [cmd] | [what it does] |

[Link to .context/stack.md for exhaustive list]
```

**Code Conventions** — From `conventions.md`:
```markdown
## Code Conventions
[Key 3-5 rules from conventions.md]
[Link to .context/conventions.md for gotchas and exceptions]
```

**Boundaries** — From `concerns.md`:
```markdown
## Boundaries
- Never: [things that hurt in the past, from concerns.md]
- [Additional constraints from concerns.md]
```

Humans read CLAUDE.md; agents and future developers reference `.context/` files for detail. Keep CLAUDE.md concise and forward-facing.

### Step 5: Verify (Mandatory)

Pick **3 specific claims** from your `.context/` files. Verify them against the actual code:

**Example spot-checks:**
- `.context/stack.md` says "React 18 + TypeScript 5" — check package.json
- `.context/conventions.md` says "Tests colocate next to source" — find a real example of a colocated test file
- `.context/architecture.md` says "API layer wraps database queries" — read one actual route handler and verify

If any claim is wrong, fix it now. Don't commit context docs that hallucinated details.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just read the code when I need it" | You'll re-read the same patterns repeatedly. Context docs are a 2-hour upfront investment that saves 20 hours of code-reading. |
| "The README is good enough" | READMEs describe how to *run* the code. `.context/` describes how it's *organized*. Different purposes, both needed. |
| "Parallel agents will miss details" | They're not writing a formal spec — they're writing *discoverable pointers to evidence*. Depth comes from agents reading `.context/` when building, not from a 200-page document. |
| "This is overhead we can't afford" | It's not overhead. It's building the foundation that all subsequent skills depend on. Skip it, and `spec-driven-development`, `planning`, and `code-review` all become slower. |
| ".context/ files will go stale" | That's fine. They're not gospel — they're starting points. When you find something wrong, fix it. If a file is stale enough to be harmful, re-run this skill. |

## Red Flags

- Agents write summaries instead of dimension files. **Stop them.** They should write directly to `.context/` and return one-sentence confirmation only.
- `.context/OVERVIEW.md` is longer than one screen. **Too detailed.** It should be a quick index, not a deep dive.
- No spot-check step — context is committed without verifying claims. **Verify before pushing.** Hallucinated context breaks downstream work.
- `.context/` files contradict each other (e.g., stack says PostgreSQL but architecture mentions "MongoDB queries"). **Resolve these before moving on.** They point to documentation or code rot.
- CLAUDE.md exists but doesn't reference `.context/`. **Link them.** CLAUDE.md is the rules file; `.context/` is the evidence. Keep them synchronized.

## Verification

Before finishing:

- [ ] All 5 files exist in `.context/`: `project.md`, `stack.md`, `architecture.md`, `conventions.md`, `concerns.md`
- [ ] `.context/OVERVIEW.md` summarizes all 5 on one screen and links to them
- [ ] 3 specific claims from `.context/` have been spot-checked against actual code
- [ ] CLAUDE.md exists and references `.context/` for details
- [ ] No `.context/` file is longer than 3 screens (dimension files should be scannable, not encyclopedic)
- [ ] Tech stack, major dependencies, and build/test commands match between `.context/stack.md` and actual project files (package.json, Dockerfile, CI config)

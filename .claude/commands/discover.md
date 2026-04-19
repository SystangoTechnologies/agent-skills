---
description: Map an existing codebase — business purpose, tech stack, architecture, conventions, and concerns
---

Invoke the sys:brownfield-discovery skill.

Map the codebase systematically to understand what it does, how it's built, how it's organized, and what hurts.

**Step 1: Decide Scope**

Choose explicitly: are you mapping the entire project or one module/service? State the scope clearly before proceeding.

**Step 2: Spawn 5 Parallel Agents**

Deploy 5 parallel Explore agents, each writing exactly one file to `.context/`:

- **Project** (.context/project.md) — What does this project do? Who uses it? What problems does it solve?
- **Stack** (.context/stack.md) — Tech dependencies, runtime versions, build/test/run commands, deployment target
- **Architecture** (.context/architecture.md) — Code organization, layers, boundaries, how components communicate
- **Conventions** (.context/conventions.md) — Code style rules, naming patterns, testing approach, gotchas
- **Concerns** (.context/concerns.md) — Tech debt, broken tests, fragile areas, high-risk modules, pain points

**Step 3: Synthesize into OVERVIEW.md**

Read all 5 files. Write `.context/OVERVIEW.md` as a one-screen index that summarizes the project and directs agents to the right dimension file based on their task.

**Step 4: Update CLAUDE.md**

Using discovered facts, create or update `CLAUDE.md` at project root with Tech Stack, Commands, Code Conventions, and Boundaries sections. Keep it concise; link to `.context/` for details.

**Step 5: Verify (Mandatory)**

Pick 3 specific claims from `.context/` files and verify them against actual code (e.g., check package.json matches stack.md, find a test file to verify conventions.md, read one route handler to verify architecture.md). Fix any incorrect claims before proceeding.

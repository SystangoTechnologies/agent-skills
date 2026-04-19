---
description: Execute a small, ad-hoc task with one short plan and one atomic commit — skips /spec and /plan
---

Invoke the sys:quick-task-execution skill.

For the task described in the arguments:

1. **Write the plan** at `specs/quick/{slug}.md` — Goal, Files likely touched, Acceptance criteria, Verification
2. **Identify the domain** — UI → `frontend-ui-engineering`; API/interface → `api-and-interface-design`; auth/input/PII → `security-and-hardening`
3. **Load the domain skill** and state it before writing any code
4. **Implement** the change, keeping the build green as you go
5. **Verify** — run every command in the plan's Verification block and check each acceptance box
6. **Commit atomically** via `git-workflow-and-versioning` — one commit, scoped to this task, plan file staged alongside the code

If the change is multi-file across domains, introduces a new public interface, or has real ambiguity about *what* to build — stop and use `/spec` → `/plan` → `/build` instead.

If verification fails, follow `sys:debugging-and-error-recovery`.

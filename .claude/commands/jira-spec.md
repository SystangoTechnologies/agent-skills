---
description: Create a Jira story-based spec after validating MCP connectivity
---

Invoke the `sys:jira-spec-driven-development` skill.

Begin by validating Jira MCP connectivity and establishing the Jira story/task context.

If Jira MCP is unavailable, stop and ask the user to connect/authenticate before proceeding.

Ask the user: "Would you also like to pull any additional context?" and incorporate it if provided.

Then ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

If a story key is provided and Jira MCP is connected, fetch the Jira context first and use it as baseline requirements.
Also check whether the story/ticket description mentions related Jira stories/tasks; if found and accessible, fetch and use their relevant context too.
Do not create specs for those related/dependency tickets - use their context only while focusing on the current ticket requested by the user.

Then generate a structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries.

Save the spec as `spec-{story-id}.md` in `{project-root}/jira-spec/{story-id}/` (example: `jira-spec/VS-10/spec-VS-10.md`) and confirm with the user before proceeding.

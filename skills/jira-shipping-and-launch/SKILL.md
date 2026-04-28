---
name: jira-shipping-and-launch
description: Prepares production launches and updates Jira ticket/task comments. Use when preparing to deploy to production and when launch readiness/progress must be communicated in Jira.
---

# Jira Shipping and Launch

## Overview

Ship with confidence. The goal is not just to deploy - it's to deploy safely, with monitoring in place, a rollback plan ready, and a clear understanding of what success looks like. Every launch should be reversible, observable, and incremental.

This is the same shipping discipline as `shipping-and-launch` with one mandatory addition: update the relevant Jira ticket/task comment with launch readiness or rollout status.

## When to Use

- Deploying a feature to production for the first time
- Releasing a significant change to users
- Migrating data or infrastructure
- Opening a beta or early access program
- Any deployment that carries risk (all of them)

## The Pre-Launch Checklist

### Code Quality

- [ ] All tests pass (unit, integration, e2e)
- [ ] Build succeeds with no warnings
- [ ] Lint and type checking pass
- [ ] Code reviewed and approved
- [ ] No TODO comments that should be resolved before launch
- [ ] No `console.log` debugging statements in production code
- [ ] Error handling covers expected failure modes

### Security

- [ ] No secrets in code or version control
- [ ] `npm audit` shows no critical or high vulnerabilities
- [ ] Input validation on all user-facing endpoints
- [ ] Authentication and authorization checks in place
- [ ] Security headers configured (CSP, HSTS, etc.)
- [ ] Rate limiting on authentication endpoints
- [ ] CORS configured to specific origins (not wildcard)

### Performance

- [ ] Core Web Vitals within "Good" thresholds
- [ ] No N+1 queries in critical paths
- [ ] Images optimized (compression, responsive sizes, lazy loading)
- [ ] Bundle size within budget
- [ ] Database queries have appropriate indexes
- [ ] Caching configured for static assets and repeated queries

### Documentation

- [ ] README updated with any new setup requirements
- [ ] API documentation current
- [ ] ADRs written for any architectural decisions
- [ ] Changelog updated
- [ ] User-facing documentation updated (if applicable)

### Jira Update

- [ ] Jira MCP connectivity verified before attempting comment updates
- [ ] Target Jira story/task key confirmed
- [ ] Ticket/task comment posted with launch readiness summary
- [ ] Comment includes: deployment scope, checklist status, risks, rollback plan, and next checkpoint

## Jira Comment Template

Use this structure when posting the Jira comment:

```markdown
Launch update:
- Scope: [what is shipping]
- Checklist status: [passed checks + any pending items]
- Risks: [known risk and mitigation]
```

## Verification

- [ ] Pre-launch checklist completed (all sections green)
- [ ] Jira ticket/task comment updated with launch readiness/progress

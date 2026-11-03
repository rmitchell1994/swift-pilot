---
name: document-plan
description: Write or update a docs/plans/ entry recording why a piece of a repo's own work was done the way it was. Use proactively immediately after implementing a non-trivial fix or feature in a repo that keeps this convention (a bug with a real root cause, a feature, an incident response) — not for trivial changes (typos, dependency bumps, formatting).
---

# document-plan

This skill defines the **shape** of a `docs/plans/` entry. It does not do the thinking — by the time this is invoked, the investigation is already done and the code is already written or reviewed. This skill's only job is to make sure that thinking gets written down in the same structure every time, so entries are easy to scan and compare later.

## When to use

Immediately after finishing implementation on a non-trivial issue (or tightly-linked group of issues fixed in one PR) in a repo that keeps a `docs/plans/` history.

Skip it for repos that don't use this convention, and skip it for: typo fixes, dependency bumps, pure formatting/lint cleanup, anything with no real "why" beyond "it was wrong."

## Where it goes

`docs/plans/<issue-number(s)>-<short-slug>.md` in the repo being worked on — see that repo's `docs/plans/README.md` for naming, if present. Never edit a past entry to change its conclusions after the fact; if something written here turns out wrong, a later entry supersedes it and says so explicitly (same convention as ARCHITECTURE.md's ADRs).

Exactly one `docs/plans/<N>-*.md` entry is expected per issue, and you (the implementing agent) author it. gem-bot only generates a stub when no entry matching the issue exists, so write yours before finishing; a second file for the same issue fails the PR check.

## Template

```markdown
# Issue #<N>[, #<M>, ...] — <short title>

**Status:** merged (PR #<N>) | in progress | superseded by <link>
**Date:** <YYYY-MM-DD>

## What happened

The triggering observation — a live incident, a review comment, a user question, a bug found while working on something else. Concrete and specific: what was seen, not a general description of the problem area.

## Investigation

What was actually checked, in what order, and what it showed. If an initial theory turned out wrong, say so and say why it was wrong before describing what was actually found — this is the most valuable part of the entry; a clean narrative that omits the wrong turn is less useful than an honest one that shows how the real cause was found.

## Decision

What was actually built or changed, and why this approach specifically.

## Alternatives considered

Bulleted. Each with a one-line reason it was rejected. Skip this section only if there was genuinely one obvious approach with nothing else worth naming.

## Outcome

PR link, what shipped, any follow-up issues raised as a result (link them).
```

## Rules

- **One entry per issue, or per tightly-linked group fixed together in one PR** (e.g. four causally-linked bugs found investigating the same incident) — not one entry per PR if the PR bundles unrelated things, and not one giant entry that accumulates every issue in a repo's history.
- **Write it once the work is done**, not as a plan-ahead document — this is history, not a proposal. (Plan-ahead proposals belong in a Plan tool session or a GitHub issue, not here.)
- **Don't duplicate ARCHITECTURE.md.** If what you're documenting is actually a durable, cross-cutting decision (a new convention, a new policy that applies broadly), that's an ADR entry in ARCHITECTURE.md instead — or in addition to, if the incident that triggered the ADR is itself worth recording here. When both apply, the docs/plans/ entry's Decision section should link to the new ADR by number rather than restating it.
- **Be honest about gaps.** If something was deferred, raised as a follow-up issue rather than fixed, or left as a known limitation, say so in Outcome rather than presenting the work as more complete than it is.

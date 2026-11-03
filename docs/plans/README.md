# Plan history

This directory is this repo's own per-issue implementation history — distinct from `ARCHITECTURE.md`.

- **`ARCHITECTURE.md`** is durable and cross-cutting: decisions that apply broadly and should be checked before future work. It stays current; superseded entries are marked, not deleted.
- **`docs/plans/`** is narrow and backward-looking: the history of *why* a specific issue was built the way it was. One file per issue (or per tightly-linked group of issues fixed together). Entries are never edited after the fact — if something here turns out to be wrong, a later entry supersedes it and says so, the same way ADRs do.

Write one whenever you finish implementing something non-trivial in this repo: a bug fix with a real root cause, a feature, an incident response. Skip it for trivial changes (typo fixes, dependency bumps, pure formatting).

See `.claude/skills/document-plan/SKILL.md` for the enforced template and when to invoke it.

## Naming

`<issue-number(s)>-<short-slug>.md`, e.g. `164-180-181-182-orchestration-integrity.md` for a group of causally-linked issues fixed in one PR, or `170-createdat-hallucination.md` for a single issue.

Exactly one `docs/plans/<N>-*.md` is expected per issue, authored by the implementing agent. gem-bot only generates a stub when the agent wrote none, and the PR check fails on zero or more than one.

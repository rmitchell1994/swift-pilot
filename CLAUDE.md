# swift-pilot

A small repository (`rmitchell1994/swift-pilot`) whose only tracked content so far is a README and a feature spec for a duration formatter library with a command-line wrapper. No source code, manifest or build tooling has been committed yet, so the language and stack are not determined.

## Detected architecture

The snapshot is too thin to show real structure. What exists:

- `README.md`: project readme.
- `docs/features/1-duration-formatter-library-with-command-line-wrapp.md`: a feature spec, numbered `1-`, with a slugified title. It is the only description of what is meant to be built.
- `.github/workflows/gemma-docs-plans-check.yml`: a CI workflow that checks `docs/plans/` entries.

There are no entry points, tests, routing or data layer to describe. Read the feature spec before writing code.

## Key dependencies

None are visible. There is no package manifest, lockfile or toolchain config in the snapshot. Before adding a dependency, work out the language and package manager the repo is meant to use. Take them from the feature spec, the README and CI. Use that ecosystem's own tool to add the dependency.

## Inferred conventions

- Feature specs live in `docs/features/` and are named `<number>-<slugified-title>.md`. Follow that scheme for new ones.
- `docs/plans/` is the place for plan-history entries, and CI checks it.
- Beyond that, the sample has no source or test files to infer naming, layout or testing style from. Match whatever the first code commits establish.
- Don't invent build, test or lint commands. If none are documented in the README or CI, say so rather than guessing.

## Decisions that can't be inferred

- Language, framework and toolchain: <!-- fill in -->
- Build, test, lint and format commands: <!-- fill in -->
- Deployment or distribution target (for example a package registry or a binary release): <!-- fill in -->
- Review process and branch or PR conventions: <!-- fill in -->
- When to open an ADR versus just a code change: <!-- fill in -->
- Team-specific dos and don'ts: <!-- fill in -->

## Architectural decisions

`ARCHITECTURE.md` is this repo's decision log. Read it before implementing anything non-trivial. It records what was decided, why, and what was rejected. If the file doesn't exist yet, create it when you record the first decision.

When you make or recognise an architectural decision (structure, patterns, tooling or behaviour), add an ADR entry to `ARCHITECTURE.md` with:

- the decision,
- why it was made,
- the alternatives considered.

## Plan history

After finishing a non-trivial issue in this repo, invoke the `document-plan` skill to write one `docs/plans/` entry per issue, or per tightly-linked group of issues fixed together. Each entry records what was found, what was decided and what shipped. Trivial changes (typos, dependency bumps, formatting) can skip it. The `gemma-docs-plans-check` CI workflow checks these entries.
# Issue #5 — Add the duration executable with testable argument handling

**Status:** in progress
**Date:** 2026-11-03

## What happened

`DurationKit` had `DurationFormatter` from issue #4, but nothing a user could run from a shell. Issue #5 asked for a `duration` executable that takes a millisecond count and prints the formatted duration, with exit codes and messages that can be tested without spawning a process.

## Decision

- **All logic lives in `DurationKit`.** `DurationCLI.run(arguments:)` takes the argument list and returns a `CLIResult` carrying the stdout text, the stderr message and the exit code. Exit codes and messages are plain values, so unit tests assert on them directly.
- **`main.swift` only forwards and does I/O.** It passes `CommandLine.arguments` to `DurationCLI.run(arguments:)`, writes the result to the standard streams and exits with the returned code. It holds no parsing or formatting logic.
- **Exit-1 messages quote the argument with `String(reflecting:)`.** The message stays a single non-empty line even when the argument is empty or contains embedded newlines.
- **Stdout is written only when non-empty.** The executable does not emit a stray blank line on error paths.

## Alternatives considered

- **Printing and calling `exit` inside the library:** rejected because it cannot be tested without running a subprocess.
- **A subprocess-based test:** rejected because it is slower, and the contract already specifies a value-returning function.
- **swift-argument-parser:** rejected because it adds a dependency for a CLI with one argument.

## Outcome

`CLIResult`, `DurationCLI.run(arguments:)` and the thin `duration` executable are added, with XCTest coverage for `DurationCLI`. No PR number is recorded here yet, so Status stays "in progress" until the PR merges.

No `ARCHITECTURE.md` entry was added, because the decision only elaborates the feature spec.

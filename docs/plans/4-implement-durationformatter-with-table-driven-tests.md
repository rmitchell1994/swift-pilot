# Issue #4 — Implement DurationFormatter with table-driven tests

**Status:** in progress
**Date:** 2026-11-03

## What happened

The package skeleton and `DurationError` from issue #3 were in place, but `DurationKit` had no formatter. Issue #4 asked for `DurationFormatter.format(milliseconds:)` in `Sources/DurationKit/DurationFormatter.swift`, covered by XCTest tests in `Tests/DurationKitTests/DurationFormatterTests.swift`.

The issue set these requirements:

- The function is pure, with no I/O and no `Foundation` date or formatter APIs.
- It renders the two largest adjacent non-zero units (`1d 2h`, `3h 4m`, `5m 6s`, `7s`), and values under 1000 ms give `0s`.
- Sub-second remainders truncate and never round up.
- It never traps for any `Int` input, including `Int.min` and `Int.max`.
- It throws `DurationError.negative` for values below 0 and `DurationError.tooLarge` for values above `Int32.max`.
- The tests are a table of (input, expected) pairs run in a loop, with the input shown in the failure message.

## Decision

- **Validate before arithmetic.** The range check runs before any division or subtraction, so no overflow is possible for any `Int`. The negative check comes before the too-large check, and `Int32.max` itself is valid.
- **Integer-division breakdown.** Total seconds are `milliseconds / 1000`, which truncates. Days, hours, minutes and seconds are derived with integer division and remainders.
- **Omit zero units, don't skip them.** The output is the largest non-zero unit plus the next smaller unit only if that unit is non-zero. 1 day 0 hours 5 minutes therefore formats as `1d`, not `1d 5m`, and `3_605_000` formats as `1h`.
- **Table-driven XCTest, written first.** The formatting cases are one table of (input, expected) pairs run in a loop, and each assertion message includes the input. The error cases (`-1`, `Int.min`, `Int(Int32.max) + 1`, `Int.max`) are separate tests.
- **XCTest rather than Swift Testing**, as decided in the feature spec.

## Alternatives considered

- **Foundation `DateComponentsFormatter`:** rejected because the issue requires a pure function, and the formatter would round and localise the output instead of truncating to fixed `d`/`h`/`m`/`s` units.
- **A `Duration`-based implementation:** rejected because it adds nothing for integer millisecond input and would lose the exact truncation rules the contract spells out.

## Outcome

`DurationFormatter` and its table-driven tests are added to `DurationKit` and `DurationKitTests`. No PR number is recorded here yet, so Status stays "in progress" until the PR merges.

`DurationCLI` and the README are out of scope here. They are tracked as the later issues in the feature spec.

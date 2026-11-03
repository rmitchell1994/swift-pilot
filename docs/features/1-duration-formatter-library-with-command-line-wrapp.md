---
root: rmitchell1994/swift-pilot#1
nodes: [package-skeleton, duration-formatter, duration-cli, readme]
---

# Feature — Duration formatter library with command-line wrapper

**Date:** 2026-11-03

## Feature

A SwiftPM package for macOS 14+ with a pure `DurationKit` library, whose `DurationFormatter.format(milliseconds:)` renders a millisecond count as its two largest adjacent non-zero units (`1d 2h`, `3h 4m`, `5m 6s`, `7s`), and a `duration` executable that wraps it with defined exit codes. It is split into small, separately reviewable tasks so the Swift TDD flow, build/test gates and plan resume across tasks are all exercised.

## Plan

The issues below, in an order that respects their dependencies. Merging this document creates every new one and records the dependencies between them.

### 1. `package-skeleton` — Create SwiftPM package skeleton and DurationError

- Repo: rmitchell1994/swift-pilot
- Depends on: nothing
- New issue, created when this document is merged

Issue text:

> ## What to build
> Set up the SwiftPM package at the repository root (the repo currently contains only README.md).
>
> - `Package.swift` with swift-tools-version 5.9 or later and `platforms: [.macOS(.v14)]`.
> - Library target `DurationKit` (sources in `Sources/DurationKit/`).
> - Test target `DurationKitTests` (in `Tests/DurationKitTests/`), using XCTest, depending on `DurationKit`.
> - Executable target named `duration` (in `Sources/duration/`) depending on `DurationKit`. Its `main.swift` is a minimal placeholder that only compiles for now, for example an empty main. A later task fills in the real behaviour.
> - `Sources/DurationKit/DurationError.swift` defining the error type exactly as in the contract below.
> - A `.gitignore` that ignores `.build/`, `.swiftpm/` and `*.xcodeproj`.
> - `Tests/DurationKitTests/DurationErrorTests.swift` covering that `DurationError.negative(1)` equals itself and differs from `.negative(2)` and from `.tooLarge(1)`, and that both cases conform to `Error`.
>
> ## Done when
> - `swift build` and `swift test` both succeed from the repo root.
> - `swift build` produces an executable product named `duration`.
>
> ## Must not
> - Do not add `DurationFormatter` or any CLI logic.
> - Do not change README.md.

### 2. `duration-formatter` — Implement DurationFormatter with table-driven tests

- Repo: rmitchell1994/swift-pilot
- Depends on: `package-skeleton`
- New issue, created when this document is merged

Issue text:

> ## What to build
> Add `DurationFormatter` to the existing `DurationKit` library target in `Sources/DurationKit/DurationFormatter.swift`, using the signature and behaviour in the contracts below. `DurationError` already exists in `Sources/DurationKit/DurationError.swift`; reuse it and do not redefine it.
>
> The function must be pure, with no I/O and no `Foundation` date or formatter APIs.
>
> ## Tests
> Add `Tests/DurationKitTests/DurationFormatterTests.swift` using XCTest. Write the tests first, as a table of (input, expected) pairs run in a loop, with the input shown in the failure message. The table covers at least:
> - `0` -> `0s`, `1` -> `0s`, `999` -> `0s`.
> - `1000` -> `1s`, `1999` -> `1s` (truncates, never rounds up), `7_000` -> `7s`.
> - `59_999` -> `59s`, `60_000` -> `1m`.
> - `61_000` -> `1m 1s`, `330_000`+`6_000` = `336_000` -> `5m 36s`.
> - `3_600_000` -> `1h`, `3_605_000` -> `1h` (zero minutes omitted, seconds not shown), `11_040_000` -> `3h 4m`.
> - `86_400_000` -> `1d`, `93_600_000` -> `1d 2h`.
> - `Int32.max` (2_147_483_647) -> `24d 20h`.
>
> Separate tests assert:
> - `-1` throws `DurationError.negative(-1)`.
> - `Int.min` throws `.negative(Int.min)`.
> - `Int(Int32.max) + 1` throws `.tooLarge(Int(Int32.max) + 1)`.
> - `Int.max` throws `.tooLarge(Int.max)`.
>
> ## Done when
> - `swift test` passes from the repo root and exercises every row above.
> - The formatter never traps (no overflow) for any `Int` input, including `Int.min` and `Int.max`.
>
> ## Must not
> - Do not change `Package.swift`, the `duration` executable or README.md.

### 3. `duration-cli` — Add the duration executable with testable argument handling and exit codes

- Repo: rmitchell1994/swift-pilot
- Depends on: `duration-formatter`
- New issue, created when this document is merged

Issue text:

> ## What to build
> Implement the command-line wrapper. The logic lives in the `DurationKit` library as `DurationCLI.run(arguments:)` in `Sources/DurationKit/DurationCLI.swift`, per the contracts below. The `duration` executable (`Sources/duration/main.swift`, currently a placeholder) only forwards `CommandLine.arguments.dropFirst()` to `DurationCLI.run`, writes `stdout` (with a trailing newline) to standard output and `stderr` (with a trailing newline, only if non-empty) to standard error, and exits with `exitCode`. No parsing or formatting logic goes in `main.swift`.
>
> `DurationFormatter` and `DurationError` already exist in `DurationKit`. Reuse them.
>
> ## Tests
> Add `Tests/DurationKitTests/DurationCLITests.swift` using XCTest, written first. Cover:
> - `["90000"]` -> stdout `1m 30s`, stderr empty, exit 0.
> - `["0"]` -> stdout `0s`, exit 0.
> - `["abc"]`, `["12.5"]` and `[""]` -> exit 1, stdout empty, stderr a single line (no embedded newline) containing the given text. For `[""]` the line must still be non-empty and identify the value, for example by quoting it.
> - `["-5"]` -> exit 1, stderr contains `-5`.
> - `["2147483648"]` -> exit 1, stderr contains `2147483648`.
> - `[]` -> exit 2, stdout empty, stderr starts with `usage: duration <milliseconds>`.
> - `["1", "2"]` -> exit 2 with the same usage line.
>
> ## Done when
> - `swift build` and `swift test` pass from the repo root.
> - Running `swift run duration 3605000` prints `1h` and exits 0; `swift run duration abc` exits 1; `swift run duration` exits 2.
>
> ## Must not
> - Do not change `DurationFormatter` behaviour, `DurationError` cases, or README.md.

### 4. `readme` — Document usage and exit codes in README

- Repo: rmitchell1994/swift-pilot
- Depends on: `duration-cli`
- New issue, created when this document is merged

Issue text:

> ## What to build
> Replace the contents of the existing `README.md` at the repo root with documentation for the package. Include:
> - A one-paragraph description of `DurationKit` and the `duration` executable, and the requirement of macOS 14+ with a Swift toolchain.
> - Build and test instructions: `swift build`, `swift test`, and `swift run duration <milliseconds>`.
> - Library usage: a short Swift snippet calling `try DurationFormatter.format(milliseconds: 93_600_000)` that returns `1d 2h`, and a description of `DurationError.negative` and `.tooLarge` (values above 2_147_483_647 ms).
> - The formatting rules: the largest two adjacent non-zero units, truncation of sub-second remainders, `0s` for anything under 1000 ms, and omission of zero units, with examples (`59_999` -> `59s`, `60_000` -> `1m`, `3_605_000` -> `1h`).
> - An exit-code table for the `duration` command: `0` success (formatted value on stdout), `1` invalid input (non-numeric, negative or too large; one line naming the value on stderr), `2` usage error (no argument or more than one; usage on stderr).
>
> ## Done when
> - README.md contains the exit-code table with exactly the codes 0, 1 and 2 as described, and every example in it matches the actual output of the built `duration` command.
>
> ## Must not
> - Do not change any file other than README.md.

## Contracts

Each contract is copied word for word into the issues it applies to.

Applies to `package-skeleton`, `duration-formatter`, `duration-cli`:

> DurationError (public, in target DurationKit, file Sources/DurationKit/DurationError.swift): `public enum DurationError: Error, Equatable { case negative(Int); case tooLarge(Int) }`. The enum is closed: exactly these two cases, and the associated Int is the offending input value in milliseconds. `negative` is thrown for any value < 0. `tooLarge` is thrown for any value > Int(Int32.max) (2_147_483_647).

Applies to `duration-formatter`, `duration-cli`, `readme`:

> DurationFormatter (public, in target DurationKit, file Sources/DurationKit/DurationFormatter.swift): `public enum DurationFormatter { public static func format(milliseconds: Int) throws -> String }`. Output is the largest non-zero unit among d/h/m/s plus the next smaller unit only if that is non-zero, joined by a single space (`1d 2h`, `3h 4m`, `5m 6s`, `7s`). Values 0..<1000 return `0s`. Sub-second remainders truncate (total seconds = milliseconds / 1000, integer division). Errors: see DurationError.

Applies to `duration-cli`, `readme`:

> CLI contract (library function in DurationKit, file Sources/DurationKit/DurationCLI.swift): `public struct CLIResult: Equatable { public let stdout: String; public let stderr: String; public let exitCode: Int32 }` and `public enum DurationCLI { public static func run(arguments: [String]) -> CLIResult }`, where `arguments` excludes the program name. Behaviour: exactly one argument that parses as Int and formats successfully gives stdout = formatted value, stderr = "", exitCode 0. Any argument that is not an Int, or that makes DurationFormatter throw, gives stdout = "", stderr = one line containing the offending argument text, exitCode 1. Zero arguments or more than one argument gives stdout = "", stderr = a usage line starting with `usage: duration <milliseconds>`, exitCode 2. The `duration` executable's main only forwards CommandLine.arguments.dropFirst(), writes stdout and stderr, and exits with exitCode.

## Assumptions

- The toolchain supports XCTest, so tests use XCTest rather than Swift Testing.
- `swift-tools-version` 5.9 or later is acceptable, and the repo's default branch is `master`.
- 'Adjacent' means the next smaller unit only. A zero unit is omitted rather than skipped over, so 1 day 0 hours 5 minutes formats as `1d`, not `1d 5m`.
- Exactly one argument is expected. Two or more arguments are treated as a usage error (usage on stderr, exit 2).
- Invalid input for the CLI means a non-integer string, a negative value, or a value above `Int32.max`. Each prints one stderr line that contains the offending value and exits 1.
- Negative values are checked before the too-large check. `Int32.max` itself is valid.

## Decisions

- No clarifying questions were asked. The issue specifies behaviour, boundaries, error types and exit codes precisely enough to plan from.
- The four-task split in the issue is kept, since each piece builds on the last and can be reviewed separately. The skeleton includes a compiling placeholder executable so `swift build` succeeds from the first merge.
- XCTest is chosen over Swift Testing because it works with every macOS 14 toolchain.
- All CLI logic is placed in `DurationKit` as `DurationCLI.run(arguments:)`, returning a value (`CLIResult`) instead of printing or exiting, so exit codes and messages can be unit tested without spawning a process. `main.swift` stays a thin forwarder.
- The tasks form a linear chain, because each one needs the previous task's code to exist and the issue asks for resume to be tested between tasks 2 and 3.
- `DurationError` is shared by three nodes, so it is defined once as a contract. The same applies to the formatter signature and the CLI contract.

No clarifying questions were asked.

## Conditions for done

- [ ] `swift build` succeeds from the repo root and produces an executable named `duration`.
- [ ] `swift test` passes from the repo root.
- [ ] `Package.swift` declares `platforms: [.macOS(.v14)]`, a library target `DurationKit`, a test target `DurationKitTests` and an executable target `duration` that depends on `DurationKit`.
- [ ] `DurationError` is `public enum DurationError: Error, Equatable` with exactly the cases `negative(Int)` and `tooLarge(Int)`.
- [ ] `DurationFormatter.format(milliseconds:)` returns `0s` for inputs 0, 1 and 999, and a test covers each.
- [ ] `DurationFormatter.format(milliseconds: 1999)` returns `1s`, and a test covers it.
- [ ] `DurationFormatter.format` returns `59s` for 59_999, `1m` for 60_000, `1h` for 3_600_000 and `1d` for 86_400_000, and tests cover each.
- [ ] `DurationFormatter.format(milliseconds: 3_605_000)` returns `1h`, and a test covers it.
- [ ] `DurationFormatter.format` returns `1d 2h` for 93_600_000, `3h 4m` for 11_040_000 and `5m 36s` for 336_000, and tests cover each.
- [ ] `DurationFormatter.format(milliseconds: -1)` throws `DurationError.negative(-1)`, and a test covers it.
- [ ] `DurationFormatter.format(milliseconds: 2_147_483_648)` throws `DurationError.tooLarge(2_147_483_648)`, and `Int32.max` itself formats successfully; tests cover both.
- [ ] `DurationFormatter` tests are table-driven, with the failing input shown in the assertion message.
- [ ] `swift run duration 3605000` prints `1h` to stdout and exits 0.
- [ ] `swift run duration abc` prints exactly one line to stderr containing `abc` and exits 1.
- [ ] `swift run duration` with no arguments prints a line starting with `usage: duration <milliseconds>` to stderr and exits 2.
- [ ] `Sources/duration/main.swift` contains no parsing or formatting logic and only forwards to `DurationCLI.run`.
- [ ] `DurationCLITests` cover exit codes 0, 1 and 2 by calling `DurationCLI.run(arguments:)` directly.
- [ ] README.md documents build and test commands, library usage, the formatting rules and a table of the `duration` exit codes 0, 1 and 2.

## Issue tree

This block is what gem-bot reads when the document is merged. The sections above are generated from it, so a hand edit to one must be matched in the other.

```gemma-feature-tree
{
  "title": "Duration formatter library with command-line wrapper",
  "summary": "A SwiftPM package for macOS 14+ with a pure `DurationKit` library, whose `DurationFormatter.format(milliseconds:)` renders a millisecond count as its two largest adjacent non-zero units (`1d 2h`, `3h 4m`, `5m 6s`, `7s`), and a `duration` executable that wraps it with defined exit codes. It is split into small, separately reviewable tasks so the Swift TDD flow, build/test gates and plan resume across tasks are all exercised.",
  "assumptions": [
    "The toolchain supports XCTest, so tests use XCTest rather than Swift Testing.",
    "`swift-tools-version` 5.9 or later is acceptable, and the repo's default branch is `master`.",
    "'Adjacent' means the next smaller unit only. A zero unit is omitted rather than skipped over, so 1 day 0 hours 5 minutes formats as `1d`, not `1d 5m`.",
    "Exactly one argument is expected. Two or more arguments are treated as a usage error (usage on stderr, exit 2).",
    "Invalid input for the CLI means a non-integer string, a negative value, or a value above `Int32.max`. Each prints one stderr line that contains the offending value and exits 1.",
    "Negative values are checked before the too-large check. `Int32.max` itself is valid."
  ],
  "contracts": [
    {
      "text": "DurationError (public, in target DurationKit, file Sources/DurationKit/DurationError.swift): `public enum DurationError: Error, Equatable { case negative(Int); case tooLarge(Int) }`. The enum is closed: exactly these two cases, and the associated Int is the offending input value in milliseconds. `negative` is thrown for any value < 0. `tooLarge` is thrown for any value > Int(Int32.max) (2_147_483_647).",
      "appliesTo": [
        "package-skeleton",
        "duration-formatter",
        "duration-cli"
      ]
    },
    {
      "text": "DurationFormatter (public, in target DurationKit, file Sources/DurationKit/DurationFormatter.swift): `public enum DurationFormatter { public static func format(milliseconds: Int) throws -> String }`. Output is the largest non-zero unit among d/h/m/s plus the next smaller unit only if that is non-zero, joined by a single space (`1d 2h`, `3h 4m`, `5m 6s`, `7s`). Values 0..<1000 return `0s`. Sub-second remainders truncate (total seconds = milliseconds / 1000, integer division). Errors: see DurationError.",
      "appliesTo": [
        "duration-formatter",
        "duration-cli",
        "readme"
      ]
    },
    {
      "text": "CLI contract (library function in DurationKit, file Sources/DurationKit/DurationCLI.swift): `public struct CLIResult: Equatable { public let stdout: String; public let stderr: String; public let exitCode: Int32 }` and `public enum DurationCLI { public static func run(arguments: [String]) -> CLIResult }`, where `arguments` excludes the program name. Behaviour: exactly one argument that parses as Int and formats successfully gives stdout = formatted value, stderr = \"\", exitCode 0. Any argument that is not an Int, or that makes DurationFormatter throw, gives stdout = \"\", stderr = one line containing the offending argument text, exitCode 1. Zero arguments or more than one argument gives stdout = \"\", stderr = a usage line starting with `usage: duration <milliseconds>`, exitCode 2. The `duration` executable's main only forwards CommandLine.arguments.dropFirst(), writes stdout and stderr, and exits with exitCode.",
      "appliesTo": [
        "duration-cli",
        "readme"
      ]
    }
  ],
  "decisions": [
    "No clarifying questions were asked. The issue specifies behaviour, boundaries, error types and exit codes precisely enough to plan from.",
    "The four-task split in the issue is kept, since each piece builds on the last and can be reviewed separately. The skeleton includes a compiling placeholder executable so `swift build` succeeds from the first merge.",
    "XCTest is chosen over Swift Testing because it works with every macOS 14 toolchain.",
    "All CLI logic is placed in `DurationKit` as `DurationCLI.run(arguments:)`, returning a value (`CLIResult`) instead of printing or exiting, so exit codes and messages can be unit tested without spawning a process. `main.swift` stays a thin forwarder.",
    "The tasks form a linear chain, because each one needs the previous task's code to exist and the issue asks for resume to be tested between tasks 2 and 3.",
    "`DurationError` is shared by three nodes, so it is defined once as a contract. The same applies to the formatter signature and the CLI contract."
  ],
  "conditionsForDone": [
    "`swift build` succeeds from the repo root and produces an executable named `duration`.",
    "`swift test` passes from the repo root.",
    "`Package.swift` declares `platforms: [.macOS(.v14)]`, a library target `DurationKit`, a test target `DurationKitTests` and an executable target `duration` that depends on `DurationKit`.",
    "`DurationError` is `public enum DurationError: Error, Equatable` with exactly the cases `negative(Int)` and `tooLarge(Int)`.",
    "`DurationFormatter.format(milliseconds:)` returns `0s` for inputs 0, 1 and 999, and a test covers each.",
    "`DurationFormatter.format(milliseconds: 1999)` returns `1s`, and a test covers it.",
    "`DurationFormatter.format` returns `59s` for 59_999, `1m` for 60_000, `1h` for 3_600_000 and `1d` for 86_400_000, and tests cover each.",
    "`DurationFormatter.format(milliseconds: 3_605_000)` returns `1h`, and a test covers it.",
    "`DurationFormatter.format` returns `1d 2h` for 93_600_000, `3h 4m` for 11_040_000 and `5m 36s` for 336_000, and tests cover each.",
    "`DurationFormatter.format(milliseconds: -1)` throws `DurationError.negative(-1)`, and a test covers it.",
    "`DurationFormatter.format(milliseconds: 2_147_483_648)` throws `DurationError.tooLarge(2_147_483_648)`, and `Int32.max` itself formats successfully; tests cover both.",
    "`DurationFormatter` tests are table-driven, with the failing input shown in the assertion message.",
    "`swift run duration 3605000` prints `1h` to stdout and exits 0.",
    "`swift run duration abc` prints exactly one line to stderr containing `abc` and exits 1.",
    "`swift run duration` with no arguments prints a line starting with `usage: duration <milliseconds>` to stderr and exits 2.",
    "`Sources/duration/main.swift` contains no parsing or formatting logic and only forwards to `DurationCLI.run`.",
    "`DurationCLITests` cover exit codes 0, 1 and 2 by calling `DurationCLI.run(arguments:)` directly.",
    "README.md documents build and test commands, library usage, the formatting rules and a table of the `duration` exit codes 0, 1 and 2."
  ],
  "nodes": [
    {
      "key": "package-skeleton",
      "title": "Create SwiftPM package skeleton and DurationError",
      "body": "## What to build\nSet up the SwiftPM package at the repository root (the repo currently contains only README.md).\n\n- `Package.swift` with swift-tools-version 5.9 or later and `platforms: [.macOS(.v14)]`.\n- Library target `DurationKit` (sources in `Sources/DurationKit/`).\n- Test target `DurationKitTests` (in `Tests/DurationKitTests/`), using XCTest, depending on `DurationKit`.\n- Executable target named `duration` (in `Sources/duration/`) depending on `DurationKit`. Its `main.swift` is a minimal placeholder that only compiles for now, for example an empty main. A later task fills in the real behaviour.\n- `Sources/DurationKit/DurationError.swift` defining the error type exactly as in the contract below.\n- A `.gitignore` that ignores `.build/`, `.swiftpm/` and `*.xcodeproj`.\n- `Tests/DurationKitTests/DurationErrorTests.swift` covering that `DurationError.negative(1)` equals itself and differs from `.negative(2)` and from `.tooLarge(1)`, and that both cases conform to `Error`.\n\n## Done when\n- `swift build` and `swift test` both succeed from the repo root.\n- `swift build` produces an executable product named `duration`.\n\n## Must not\n- Do not add `DurationFormatter` or any CLI logic.\n- Do not change README.md.",
      "repo": "rmitchell1994/swift-pilot",
      "dependsOn": []
    },
    {
      "key": "duration-formatter",
      "title": "Implement DurationFormatter with table-driven tests",
      "body": "## What to build\nAdd `DurationFormatter` to the existing `DurationKit` library target in `Sources/DurationKit/DurationFormatter.swift`, using the signature and behaviour in the contracts below. `DurationError` already exists in `Sources/DurationKit/DurationError.swift`; reuse it and do not redefine it.\n\nThe function must be pure, with no I/O and no `Foundation` date or formatter APIs.\n\n## Tests\nAdd `Tests/DurationKitTests/DurationFormatterTests.swift` using XCTest. Write the tests first, as a table of (input, expected) pairs run in a loop, with the input shown in the failure message. The table covers at least:\n- `0` -> `0s`, `1` -> `0s`, `999` -> `0s`.\n- `1000` -> `1s`, `1999` -> `1s` (truncates, never rounds up), `7_000` -> `7s`.\n- `59_999` -> `59s`, `60_000` -> `1m`.\n- `61_000` -> `1m 1s`, `330_000`+`6_000` = `336_000` -> `5m 36s`.\n- `3_600_000` -> `1h`, `3_605_000` -> `1h` (zero minutes omitted, seconds not shown), `11_040_000` -> `3h 4m`.\n- `86_400_000` -> `1d`, `93_600_000` -> `1d 2h`.\n- `Int32.max` (2_147_483_647) -> `24d 20h`.\n\nSeparate tests assert:\n- `-1` throws `DurationError.negative(-1)`.\n- `Int.min` throws `.negative(Int.min)`.\n- `Int(Int32.max) + 1` throws `.tooLarge(Int(Int32.max) + 1)`.\n- `Int.max` throws `.tooLarge(Int.max)`.\n\n## Done when\n- `swift test` passes from the repo root and exercises every row above.\n- The formatter never traps (no overflow) for any `Int` input, including `Int.min` and `Int.max`.\n\n## Must not\n- Do not change `Package.swift`, the `duration` executable or README.md.",
      "repo": "rmitchell1994/swift-pilot",
      "dependsOn": [
        "package-skeleton"
      ]
    },
    {
      "key": "duration-cli",
      "title": "Add the duration executable with testable argument handling and exit codes",
      "body": "## What to build\nImplement the command-line wrapper. The logic lives in the `DurationKit` library as `DurationCLI.run(arguments:)` in `Sources/DurationKit/DurationCLI.swift`, per the contracts below. The `duration` executable (`Sources/duration/main.swift`, currently a placeholder) only forwards `CommandLine.arguments.dropFirst()` to `DurationCLI.run`, writes `stdout` (with a trailing newline) to standard output and `stderr` (with a trailing newline, only if non-empty) to standard error, and exits with `exitCode`. No parsing or formatting logic goes in `main.swift`.\n\n`DurationFormatter` and `DurationError` already exist in `DurationKit`. Reuse them.\n\n## Tests\nAdd `Tests/DurationKitTests/DurationCLITests.swift` using XCTest, written first. Cover:\n- `[\"90000\"]` -> stdout `1m 30s`, stderr empty, exit 0.\n- `[\"0\"]` -> stdout `0s`, exit 0.\n- `[\"abc\"]`, `[\"12.5\"]` and `[\"\"]` -> exit 1, stdout empty, stderr a single line (no embedded newline) containing the given text. For `[\"\"]` the line must still be non-empty and identify the value, for example by quoting it.\n- `[\"-5\"]` -> exit 1, stderr contains `-5`.\n- `[\"2147483648\"]` -> exit 1, stderr contains `2147483648`.\n- `[]` -> exit 2, stdout empty, stderr starts with `usage: duration <milliseconds>`.\n- `[\"1\", \"2\"]` -> exit 2 with the same usage line.\n\n## Done when\n- `swift build` and `swift test` pass from the repo root.\n- Running `swift run duration 3605000` prints `1h` and exits 0; `swift run duration abc` exits 1; `swift run duration` exits 2.\n\n## Must not\n- Do not change `DurationFormatter` behaviour, `DurationError` cases, or README.md.",
      "repo": "rmitchell1994/swift-pilot",
      "dependsOn": [
        "duration-formatter"
      ]
    },
    {
      "key": "readme",
      "title": "Document usage and exit codes in README",
      "body": "## What to build\nReplace the contents of the existing `README.md` at the repo root with documentation for the package. Include:\n- A one-paragraph description of `DurationKit` and the `duration` executable, and the requirement of macOS 14+ with a Swift toolchain.\n- Build and test instructions: `swift build`, `swift test`, and `swift run duration <milliseconds>`.\n- Library usage: a short Swift snippet calling `try DurationFormatter.format(milliseconds: 93_600_000)` that returns `1d 2h`, and a description of `DurationError.negative` and `.tooLarge` (values above 2_147_483_647 ms).\n- The formatting rules: the largest two adjacent non-zero units, truncation of sub-second remainders, `0s` for anything under 1000 ms, and omission of zero units, with examples (`59_999` -> `59s`, `60_000` -> `1m`, `3_605_000` -> `1h`).\n- An exit-code table for the `duration` command: `0` success (formatted value on stdout), `1` invalid input (non-numeric, negative or too large; one line naming the value on stderr), `2` usage error (no argument or more than one; usage on stderr).\n\n## Done when\n- README.md contains the exit-code table with exactly the codes 0, 1 and 2 as described, and every example in it matches the actual output of the built `duration` command.\n\n## Must not\n- Do not change any file other than README.md.",
      "repo": "rmitchell1994/swift-pilot",
      "dependsOn": [
        "duration-cli"
      ]
    }
  ]
}
```

_Generated by gem-bot from the approved clarifications and the repositories at planning time. It can be revised while its pull request is open and is not edited by gem-bot after it is merged._

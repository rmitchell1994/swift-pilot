# swift-pilot

`DurationKit` is a pure Swift library that renders a millisecond count as a compact duration string, and `duration` is a command-line executable that wraps it. It requires macOS 14 or later and a Swift 5.9 or later toolchain.

## Build and test

```sh
swift build
swift test
swift run duration <milliseconds>
```

## Library usage

```swift
import DurationKit

let text = try DurationFormatter.format(milliseconds: 93_600_000)
// text == "1d 2h"
```

`DurationFormatter.format(milliseconds:)` throws a `DurationError`:

- `DurationError.negative(Int)` is thrown for any value below 0.
- `DurationError.tooLarge(Int)` is thrown for any value above 2_147_483_647 ms (`Int32.max`).

The associated value is the offending input in milliseconds. `2_147_483_647` itself is valid and formats as `24d 20h`.

## Formatting rules

- The output is the largest non-zero unit among d, h, m and s, plus the next smaller unit only if that unit is non-zero, joined by a single space.
- Sub-second remainders are truncated, never rounded up.
- Anything under 1000 ms gives `0s`.
- Zero units are omitted rather than skipped over.

| Milliseconds | Output |
| --- | --- |
| `999` | `0s` |
| `1_999` | `1s` |
| `7_000` | `7s` |
| `59_999` | `59s` |
| `60_000` | `1m` |
| `336_000` | `5m 36s` |
| `3_605_000` | `1h` |
| `11_040_000` | `3h 4m` |
| `86_400_000` | `1d` |
| `93_600_000` | `1d 2h` |

## Exit codes

| Code | Meaning | Output |
| --- | --- | --- |
| `0` | Success. | The formatted value is printed on stdout. |
| `1` | Invalid input (non-numeric, negative or too large). | One line naming the value is printed on stderr. |
| `2` | Usage error (no argument, or more than one). | The usage line `usage: duration <milliseconds>` is printed on stderr. |

```sh
$ duration 3605000
1h                                                   # exit 0
$ duration abc
duration: invalid number "abc"                       # stderr, exit 1
$ duration -5
duration: "-5" is negative                           # stderr, exit 1
$ duration 2147483648
duration: "2147483648" exceeds 2147483647 ms         # stderr, exit 1
$ duration ""
duration: invalid number ""                          # stderr, exit 1
$ duration
usage: duration <milliseconds>                       # stderr, exit 2
```

The argument is quoted in the stderr line, so an empty argument still produces a non-empty line.

import XCTest

@testable import DurationKit

final class DurationCLITests: XCTestCase {
    private let usagePrefix = "usage: duration <milliseconds>"

    func testCLIResultEqualsSameFields() {
        XCTAssertEqual(
            CLIResult(stdout: "a", stderr: "b", exitCode: 1),
            CLIResult(stdout: "a", stderr: "b", exitCode: 1))
    }

    func testCLIResultDiffersWhenAnyFieldDiffers() {
        let base = CLIResult(stdout: "a", stderr: "b", exitCode: 1)
        XCTAssertNotEqual(base, CLIResult(stdout: "x", stderr: "b", exitCode: 1))
        XCTAssertNotEqual(base, CLIResult(stdout: "a", stderr: "x", exitCode: 1))
        XCTAssertNotEqual(base, CLIResult(stdout: "a", stderr: "b", exitCode: 2))
    }

    func testSuccessCases() {
        let cases: [(String, String)] = [
            ("90000", "1m 30s"),
            ("0", "0s"),
            ("2147483647", "24d 20h"),
        ]
        for (argument, expected) in cases {
            let result = DurationCLI.run(arguments: [argument])
            XCTAssertEqual(
                result, CLIResult(stdout: expected, stderr: "", exitCode: 0), "argument \(argument)")
        }
    }

    func testNonIntegerArgumentsFailWithSingleLineStderrContainingArgument() {
        let cases: [(String, String)] = [
            ("abc", "abc"),
            ("12.5", "12.5"),
            ("", "\"\""),
        ]
        for (argument, expectedFragment) in cases {
            let result = DurationCLI.run(arguments: [argument])
            XCTAssertEqual(result.exitCode, 1, "argument \(argument)")
            XCTAssertEqual(result.stdout, "", "argument \(argument)")
            XCTAssertFalse(result.stderr.isEmpty, "argument \(argument)")
            XCTAssertFalse(result.stderr.contains("\n"), "argument \(argument)")
            XCTAssertTrue(result.stderr.contains(expectedFragment), "argument \(argument)")
        }
    }

    func testNegativeArgumentFailsWithArgumentInStderr() {
        let result = DurationCLI.run(arguments: ["-5"])
        XCTAssertEqual(result.exitCode, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertTrue(result.stderr.contains("-5"))
    }

    func testTooLargeArgumentFailsWithArgumentInStderr() {
        let result = DurationCLI.run(arguments: ["2147483648"])
        XCTAssertEqual(result.exitCode, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertTrue(result.stderr.contains("2147483648"))
    }

    func testWrongArgumentCountReturnsUsageWithExitCodeTwo() {
        let cases: [[String]] = [[], ["1", "2"]]
        for arguments in cases {
            let result = DurationCLI.run(arguments: arguments)
            XCTAssertEqual(result.exitCode, 2, "arguments \(arguments)")
            XCTAssertEqual(result.stdout, "", "arguments \(arguments)")
            XCTAssertTrue(result.stderr.hasPrefix(usagePrefix), "arguments \(arguments)")
        }
    }

    func testSuccessHasEmptyStderrAndFailureHasEmptyStdout() {
        let inputs: [[String]] = [
            ["90000"], ["0"], ["2147483647"], ["abc"], ["12.5"], [""], ["-5"],
            ["2147483648"], [], ["1", "2"],
        ]
        for arguments in inputs {
            let result = DurationCLI.run(arguments: arguments)
            if result.exitCode == 0 {
                XCTAssertEqual(result.stderr, "", "arguments \(arguments)")
            } else {
                XCTAssertEqual(result.stdout, "", "arguments \(arguments)")
            }
        }
    }
}

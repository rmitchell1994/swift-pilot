import XCTest

@testable import DurationKit

final class DurationFormatterTests: XCTestCase {
    func testNegativeOneThrowsNegative() {
        XCTAssertThrowsError(try DurationFormatter.format(milliseconds: -1)) { error in
            XCTAssertEqual(error as? DurationError, .negative(-1))
        }
    }

    func testIntMinThrowsNegative() {
        XCTAssertThrowsError(try DurationFormatter.format(milliseconds: Int.min)) { error in
            XCTAssertEqual(error as? DurationError, .negative(Int.min))
        }
    }

    func testInt32MaxPlusOneThrowsTooLarge() {
        XCTAssertThrowsError(try DurationFormatter.format(milliseconds: Int(Int32.max) + 1)) { error in
            XCTAssertEqual(error as? DurationError, .tooLarge(Int(Int32.max) + 1))
        }
    }

    func testIntMaxThrowsTooLarge() {
        XCTAssertThrowsError(try DurationFormatter.format(milliseconds: Int.max)) { error in
            XCTAssertEqual(error as? DurationError, .tooLarge(Int.max))
        }
    }

    func testFormatsExpectedStringForEachInput() throws {
        let cases: [(input: Int, expected: String)] = [
            (0, "0s"),
            (1, "0s"),
            (999, "0s"),
            (1_000, "1s"),
            (1_999, "1s"),
            (7_000, "7s"),
            (59_999, "59s"),
            (60_000, "1m"),
            (61_000, "1m 1s"),
            (330_000 + 6_000, "5m 36s"),
            (3_600_000, "1h"),
            (3_605_000, "1h"),
            (11_040_000, "3h 4m"),
            (86_400_000, "1d"),
            (93_600_000, "1d 2h"),
            (Int(Int32.max), "24d 20h"),
        ]
        for (input, expected) in cases {
            let actual = try DurationFormatter.format(milliseconds: input)
            XCTAssertEqual(actual, expected, "input: \(input) ms")
        }
    }
}

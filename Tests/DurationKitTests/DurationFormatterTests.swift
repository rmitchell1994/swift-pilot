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
}

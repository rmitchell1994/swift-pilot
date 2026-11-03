import XCTest

@testable import DurationKit

final class DurationErrorTests: XCTestCase {
    func testNegativeEqualsSameNegative() {
        XCTAssertEqual(DurationError.negative(1), DurationError.negative(1))
    }

    func testNegativeDiffersFromOtherNegativeValue() {
        XCTAssertNotEqual(DurationError.negative(1), DurationError.negative(2))
    }

    func testNegativeDiffersFromTooLarge() {
        XCTAssertNotEqual(DurationError.negative(1), DurationError.tooLarge(1))
    }

    func testTooLargeEqualsSameTooLarge() {
        XCTAssertEqual(DurationError.tooLarge(1), DurationError.tooLarge(1))
    }

    func testCasesCastBackFromError() {
        let negativeError: Error = DurationError.negative(1)
        let tooLargeError: Error = DurationError.tooLarge(1)
        XCTAssertEqual(negativeError as? DurationError, .negative(1))
        XCTAssertEqual(tooLargeError as? DurationError, .tooLarge(1))
    }

    func testThrownNegativeIsCaughtEqual() {
        XCTAssertThrowsError(try throwError(.negative(1))) { error in
            XCTAssertEqual(error as? DurationError, .negative(1))
        }
    }

    func testThrownTooLargeIsCaughtEqual() {
        XCTAssertThrowsError(try throwError(.tooLarge(1))) { error in
            XCTAssertEqual(error as? DurationError, .tooLarge(1))
        }
    }

    private func throwError(_ error: DurationError) throws {
        throw error
    }
}

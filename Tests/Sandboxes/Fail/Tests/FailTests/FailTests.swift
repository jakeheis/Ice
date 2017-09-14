import XCTest
@testable import Fail

class FailTests: XCTestCase {

    static var allTests = [
        ("testAssertions", testAssertions),
    ]

    func testAssertions() {
        // Fail

        XCTFail()

        // Equality

        XCTAssertEqual("hello world", "hey world")
        XCTAssertEqual("hello world", "hey world", "The strings should be equal")

        XCTAssertEqual("first line\nsecondline", "first line\nthird line")
        XCTAssertEqual("first line\nsecondline", "first line\nthird line", "The multiline strings should be equal")

        XCTAssertEqual(4.0, 5.0, accuracy: 0.5)

        XCTAssertNotEqual("hello world", "hello world")
        XCTAssertNotEqual("first line\nsecondline", "first line\nsecondline")

        XCTAssertNotEqual(4.0, 4.5, accuracy: 0.5)

        // Nil

        XCTAssertNil("a value", "The value should be nil")
        XCTAssertNotNil(nil, "The value should not be nil")

        // Comparison
        XCTAssertGreaterThan(1, 4, "one should be greater than four")
        XCTAssertLessThan(4, 1)
        XCTAssertGreaterThanOrEqual(1, 4)
        XCTAssertLessThanOrEqual(4, 1)

        // Boolean
        XCTAssertTrue(false)
        XCTAssertFalse(true)
        XCTAssert(false)

        // Throwing
        XCTAssertThrowsError(try nonThrower())
        XCTAssertNoThrow(try thrower())
    }

    private func nonThrower() throws {}

    private func thrower() throws {
        throw NSError(domain: "ice", code: 1, userInfo: nil)
    }

}

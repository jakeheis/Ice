import XCTest
@testable import Lib

class LibTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Lib().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}

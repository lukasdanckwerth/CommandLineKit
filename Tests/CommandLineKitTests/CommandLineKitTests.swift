import XCTest
@testable import CommandLineKit

final class CommandLineKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CommandLineKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

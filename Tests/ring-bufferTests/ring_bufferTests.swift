import XCTest
@testable import ring_buffer

final class ring_bufferTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ring_buffer().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

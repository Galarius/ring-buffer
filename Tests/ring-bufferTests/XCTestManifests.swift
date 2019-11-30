import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ring_bufferTests.allTests),
        testCase(ring_bufferThreadsTests.allTests),
    ]
}
#endif

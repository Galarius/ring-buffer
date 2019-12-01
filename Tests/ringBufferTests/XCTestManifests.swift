import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ringBufferTests.allTests),
        testCase(ringBufferThreadsTests.allTests)
    ]
}
#endif

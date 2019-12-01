import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RingBufferSingleItemTests.allTests),
        testCase(RingBufferMultipleItemsTests.allTests),
        testCase(RingBufferThreadsTests.allTests)
    ]
}
#endif

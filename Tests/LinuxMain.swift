import XCTest

import RingBufferSingleItemTests
import RingBufferMultipleItemsTests
import RingBufferThreadsTests

var tests = [XCTestCaseEntry]()
tests += RingBufferSingleItemTests.allTests()
tests += RingBufferMultipleItemsTests.allTests()
tests += RingBufferThreadsTests.allTests()
XCTMain(tests)

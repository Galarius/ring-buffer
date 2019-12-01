import XCTest

import ringBufferTests

var tests = [XCTestCaseEntry]()
tests += ringBufferTests.allTests()
XCTMain(tests)

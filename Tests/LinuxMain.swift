import XCTest

import ring_bufferTests

var tests = [XCTestCaseEntry]()
tests += ring_bufferTests.allTests()
XCTMain(tests)

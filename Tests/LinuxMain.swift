#if os(Linux)

import XCTest
@testable import MySQLTestSuite

XCTMain([
    testCase(ConsoleTests.allTests)
])

#endif
#if os(Linux)

import XCTest
@testable import MySQLTestSuite

XCTMain([
    testCase(MySQLTests.allTests)
])

#endif
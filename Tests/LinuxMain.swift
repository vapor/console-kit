#if os(Linux)

import XCTest
@testable import FluentMySQLTestSuite

XCTMain([
    testCase(MySQLTests.allTests),
    testCase(MySQLDriverTests.allTests),
])

#endif
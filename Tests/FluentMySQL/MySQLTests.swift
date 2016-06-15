import XCTest
@testable import FluentMySQL

class MySQLTests: XCTestCase {
    static let allTests = [
        ("testSelectVersion", testSelectVersion)
    ]

    func testSelectVersion() {
        let mysql = MySQL.makeTestConnection()

        do {
            let results = try mysql.execute("SELECT @@version")

            guard let version = results.first?["@@version"] else {
                XCTFail("Version not in results")
                return
            }

            XCTAssert(version?.characters.first == "5")
        } catch {
            XCTFail("Could not select version: \(error)")
        }
    }

    func xtestTables() {
        let mysql = MySQL.makeTestConnection()

        do {
            try mysql.execute("DROP IF EXISTS TABLE foo")
            try mysql.execute("CREATE TABLE foo (bar INT(4), baz VARCHAR(16))")
            try mysql.execute("INSERT INTO foo VALUES (42, 'Life')")
            try mysql.execute("INSERT INTO foo VALUES (1337, 'Elite')")
            try mysql.execute("INSERT INTO foo VALUES (9, NULL)")

            if let resultBar = try mysql.execute("SELECT * FROM foo WHERE bar = 42").first {
                XCTAssert(resultBar["bar"] ?== "42")
                XCTAssert(resultBar["baz"] ?== "Life")
            } else {
                XCTFail("Could not get bar result")
            }


            if let resultBaz = try mysql.execute("SELECT * FROM foo where baz = 'Elite'").first {
                XCTAssert(resultBaz["bar"] ?== "1337")
                XCTAssert(resultBaz["baz"] ?== "Elite")
            } else {
                XCTFail("Could not get baz result")
            }

            if let resultBaz = try mysql.execute("SELECT * FROM foo where bar = 9").first {
                XCTAssert(resultBaz["bar"] ?== "9")
                XCTAssert(resultBaz["baz"] ?== nil)
            } else {
                XCTFail("Could not get null result")
            }
        } catch {
            XCTFail("Testing tables failed: \(error)")
        }
    }

    func xtestEscape() {
        let mysql = MySQL.makeTestConnection()

        do {
            let escaped = try mysql.escape("'DROP")
            XCTAssertEqual(escaped, "'\\\'DROP'")
        } catch {
            XCTFail("Could not escape: \(error)")
        }
    }

    func xtestParameterize() {
        let mysql = MySQL.makeTestConnection()
        
        do {
            let parameterized = try mysql.parameterize(
                "SELECT * FROM users WHERE name = ?, email = ?",
                [
                    "vapor",
                    "vapor@qutheory.io"
                ]
            )

            XCTAssertEqual(
                parameterized,
                "SELECT * FROM users WHERE name = 'vapor', email = 'vapor@qutheory.io'"
            )
        } catch {
            XCTFail("Could not parameterize: \(error)")
        }
    }
}

infix operator ?== {}

func ?==(lhs: String??, rhs: String?) -> Bool {
    guard let string = lhs else {
        return false
    }

    return (string as String?) == rhs
}
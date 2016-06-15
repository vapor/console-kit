import XCTest
@testable import FluentMySQL
import Fluent

class MySQLTests: XCTestCase {
    static let allTests = [
        ("testSelectVersion", testSelectVersion)
    ]

    var mysql: MySQL!

    override func setUp() {
        mysql = MySQL.makeTestConnection()
    }

    func testSelectVersion() {
        do {
            let results = try mysql.execute("SELECT @@version, @@version, 1337, 3.14, 'what up', NULL")

            guard let version = results.first?["@@version"] else {
                XCTFail("Version not in results")
                return
            }

            XCTAssert(version?.string?.characters.first == "5")
        } catch {
            XCTFail("Could not select version: \(error)")
        }
    }

    func testTables() {
        do {
            try mysql.execute("DROP TABLE IF EXISTS foo")
            try mysql.execute("CREATE TABLE foo (bar INT(4), baz VARCHAR(16))")
            try mysql.execute("INSERT INTO foo VALUES (42, 'Life')")
            try mysql.execute("INSERT INTO foo VALUES (1337, 'Elite')")
            try mysql.execute("INSERT INTO foo VALUES (9, NULL)")

            if let resultBar = try mysql.execute("SELECT * FROM foo WHERE bar = 42").first {
                XCTAssertEqual(resultBar["bar"]??.int, 42)
                XCTAssertEqual(resultBar["baz"]??.string, "Life")
            } else {
                XCTFail("Could not get bar result")
            }


            if let resultBaz = try mysql.execute("SELECT * FROM foo where baz = 'elite'").first {
                XCTAssertEqual(resultBaz["bar"]??.int, 1337)
                XCTAssertEqual(resultBaz["baz"]??.string, "Elite")
            } else {
                XCTFail("Could not get baz result")
            }

            if let resultBaz = try mysql.execute("SELECT * FROM foo where bar = 9").first {
                XCTAssertEqual(resultBaz["bar"]??.int, 9)
                XCTAssertEqual(resultBaz["baz"]??.string, nil)
            } else {
                XCTFail("Could not get null result")
            }
        } catch {
            XCTFail("Testing tables failed: \(error)")
        }
    }

    func testParameterization() {
        do {
            try mysql.execute("DROP TABLE IF EXISTS parameterization")
            try mysql.execute("CREATE TABLE parameterization (d DOUBLE, i INT, s VARCHAR(16), u INT UNSIGNED)")

            try mysql.execute("INSERT INTO parameterization VALUES (3.14, NULL, 'pi', NULL)")
            try mysql.execute("INSERT INTO parameterization VALUES (NULL, NULL, 'life', 42)")
            try mysql.execute("INSERT INTO parameterization VALUES (NULL, -1, 'test', NULL)")

            if let resultBar = try mysql.execute("SELECT * FROM parameterization WHERE d = ?", [.string("3.14")]).first {
                XCTAssertEqual(resultBar["d"]??.double, 3.14)
                XCTAssertEqual(resultBar["i"]??.int, nil)
                XCTAssertEqual(resultBar["s"]??.string, "pi")
                XCTAssertEqual(resultBar["u"]??.int, nil)
            } else {
                XCTFail("Could not get pi result")
            }
        } catch {
            XCTFail("Testing tables failed: \(error)")
        }
    }
}

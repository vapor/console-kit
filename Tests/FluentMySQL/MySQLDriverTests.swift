import XCTest
@testable import FluentMySQL
import Fluent
import MySQL

class MySQLDriverTests: XCTestCase {
    static let allTests = [
        ("testSaveAndFind", testSaveAndFind)
    ]

    var database: Fluent.Database!
    var driver: MySQLDriver!

    override func setUp() {
        driver = MySQLDriver(MySQL.Database.makeTestConnection())
        database = Database(driver: driver)
    }

    func testSaveAndFind() {
        try! driver.raw("DROP TABLE IF EXISTS users")
        try! driver.raw("CREATE TABLE users (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(16), email VARCHAR(32))")

        var user = User(id: nil, name: "Vapor", email: "vapor@qutheory.io")
        User.database = database

        do {
            try user.save()
        } catch {
            XCTFail("Could not save: \(error)")
        }

        do {
            let found = try User.find(1)
            XCTAssertEqual(found?.id?.string, user.id?.string)
            XCTAssertEqual(found?.name, user.name)
            XCTAssertEqual(found?.email, user.email)
        } catch {
            XCTFail("Could not find user: \(error)")
        }

        do {
            let user = try User.find(2)
            XCTAssertNil(user)
        } catch {
            XCTFail("Could not find user: \(error)")
        }
    }
}
import XCTest
import FluentMySQL

extension MySQL {
    static func makeTestConnection() -> MySQL {
        do {
            return try MySQL(
                username: "tester",
                password: "secret",
                host: "localhost",
                database: "test"
            )
        } catch {
            print()
            print()
            print("⚠️ MySQL Not Configured ⚠️")
            print()
            print("Error: \(error)")
            print()
            print("You must configure MySQL to run with the following configuration: ")
            print("    user: tester")
            print("    password: secret")
            print("    host: localhost")
            print("    database: test")
            print()

            print()

            XCTFail("Configure MySQL")
            fatalError("Configure MySQL")
        }
    }
}

import XCTest
import FluentMySQL
import Fluent

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

struct User: Model {
    var id: Value?
    var name: String
    var email: String

    init(id: Value?, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    func serialize() -> [String : Value?] {
        return [
            "id": id,
            "name": name,
            "email" :email
        ]
    }

    init?(serialized: [String : Value]) {
        id = serialized["id"]
        name = serialized["name"]?.string ?? ""
        email = serialized["email"]?.string ?? ""
    }
}

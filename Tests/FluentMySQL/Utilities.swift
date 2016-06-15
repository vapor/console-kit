import XCTest

import MySQL
import FluentMySQL
import Fluent

extension MySQL.Database {
    static func makeTestConnection() -> MySQL.Database {
        do {
            return try MySQL.Database(
                host: "127.0.0.1",
                user: "travis",
                password: "",
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
            print("    user: 'travis'")
            print("    password: '' // (empty)")
            print("    host: '127.0.0.1'")
            print("    database: 'test'")
            print()

            print()

            XCTFail("Configure MySQL")
            fatalError("Configure MySQL")
        }
    }
}

struct User: Model {
    var id: Fluent.Value?
    var name: String
    var email: String

    init(id: Fluent.Value?, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    func serialize() -> [String : Fluent.Value?] {
        return [
            "id": id,
            "name": name,
            "email" :email
        ]
    }

    init?(serialized: [String : Fluent.Value]) {
        id = serialized["id"]
        name = serialized["name"]?.string ?? ""
        email = serialized["email"]?.string ?? ""
    }
}

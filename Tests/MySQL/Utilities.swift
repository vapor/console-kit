import XCTest
import MySQL

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

// Makes fetching values during tests easier
extension MySQL.Value {
    var string: String? {
        guard case .string(let string) = self else {
            return nil
        }

        return string
    }

    var int: Int? {
        guard case .int(let int) = self else {
            return nil
        }

        return int
    }

    var double: Double? {
        guard case .double(let double) = self else {
            return nil
        }

        return double
    }

    var uint: UInt? {
        guard case .uint(let uint) = self else {
            return nil
        }

        return uint
    }
}

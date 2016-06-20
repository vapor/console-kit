# MySQL for Swift

A Swift wrapper for MySQL.

- [x] Thread-Safe
- [x] Pure Swift
- [x] Prepared Statements

This wrapper uses the latest MySQL fetch API to enable performant prepared statements and output bindings. Data is sent to and received from the MySQL server in its native data type without converting to and from strings. The Swift wrappers around the C MySQL structs and references automatically manage closing connections and deallocating memeory. Additionally, the MySQL library API is used to perform thread safe, performant queries to the database.

## Examples

### Connecting to the Database

```swift
import MySQL

let mysql = try MySQL.Database(
    host: "127.0.0.1",
    user: "root",
    password: "",
    database: "test"
)
```

### Select

```swift
let version = try mysql.execute("SELECT @@version")
```

### Prepared Statement

The second parameter to `execute()` is an array of `MySQL.Value`s.

```swift
let results = try mysql.execute("SELECT * FROM users WHERE age >= ?", [.int(21)])
```

```swift
public enum Value {
    case string(String)
    case int(Int)
    case uint(UInt)
    case double(Double)
    case null
}
```

### Connection

Each call to `execute()` creates a new connection to the MySQL database. This ensures thread safety since a single connection cannot be used on more than one thread.

If you would like to re-use a connection between calls to execute, create a reusable connection and pass it as the third parameter to `execute()`.

```swift
let connection = msyql.makeConnection()
let result = try mysql.execute("SELECT LAST_INSERTED_ID() as id", [], connection)
```

No need to worry about closing the connection.

## Fluent

This wrapper was created to power [Fluent](https://github.com/qutheory/fluent), an elegant ORM for Swift. 

## Author

Created by [Tanner Nelson](https://github.com/tannernelson).


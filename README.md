# MySQL for Swift

![Swift](https://camo.githubusercontent.com/0727f3687a1e263cac101c5387df41048641339c/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d332e302d6f72616e67652e7376673f7374796c653d666c6174)
[![Build Status](https://travis-ci.org/qutheory/mysql.svg?branch=master)](https://travis-ci.org/qutheory/mysql)

A Swift wrapper for MySQL.

- [x] Thread-Safe
- [x] Pure Swift
- [x] Prepared Statements
- [x] Tested

This wrapper uses the latest MySQL fetch API to enable performant prepared statements and output bindings. Data is sent to and received from the MySQL server in its native data type without converting to and from strings. 

The Swift wrappers around the MySQL's C structs and pointers automatically manage closing connections and deallocating memeory. Additionally, the MySQL library API is used to perform thread safe, performant queries to the database.

~40 assertions tested on Ubuntu 14.04 and macOS 10.11 on every push.

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

## Building

### macOS

Install MySQL

```shell
brew install mysql
brew link mysql
mysql.server start
```

Link MySQL during `swift build`

```swift
swift build -Xswiftc -I/usr/local/include/mysql -Xlinker -L/usr/local/lib
```

`-I` tells the compiler where to find the MySQL header files, and `-L` tells the linker where to find the library. This is required to compile and run on macOS.

### Linux

Install MySQL

```shell
sudo apt-get update
sudo apt-get install -y mysql-server libmysqlclient-dev
sudo mysql_install_db
sudo service mysql start
```

`swift build` should work normally.

### Travis

Travis builds Swift MySQL on both Ubuntu 14.04 and macOS 10.11. Check out the `.travis.yml` file to see how this package is built and compiled during testing.

## Fluent

This wrapper was created to power [Fluent](https://github.com/qutheory/fluent), an ORM for Swift. 

## Author

Created by [Tanner Nelson](https://github.com/tannernelson).


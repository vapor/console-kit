import Fluent

public class MySQLDriver: Fluent.Driver {
    private(set) var database: PostgreSQL!

    private init() {

    }

    public init(username: String, password: String, database: String, host: String? = nil, port: Int? = 0, socket: String? = nil, flag: Int = 0) {
        self.database = MySQL()
        self.database.connect(username, password, database, host, port, socket, flag)
    }

    public func fetchOne(table table: String, filters: [Filter]) -> [String: String]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filters = filters
        sql.limit = 1

        if let result = self.database.execute(sql.query) {
          return result.data.first
        }
        return nil
    }

    public func fetch(table table: String, filters: [Filter]) -> [[String: String]] {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filters = filters

        if let result = self.database.execute(sql.query) {
          return result.data
        }
        return []
    }

    public func delete(table table: String, filters: [Filter]) {
        let sql = SQL(operation: .DELETE, table: table)
        sql.filters = filters

        self.database.execute(sql.query)
    }

    public func update(table table: String, filters: [Filter], data: [String: String]) {
        let sql = SQL(operation: .UPDATE, table: table)
        sql.filters = filters
        sql.data = data

        self.database.execute(sql.query)
    }

    public func insert(table table: String, items: [[String: String]]) {
      for item in items {
        let sql = SQL(operation: .INSERT, table: table)
        sql.data = item

        self.database.execute(sql.query)
      }
    }

    public func upsert(table table: String, items: [[String: String]]) {
        //check if object exists
    }

    public func exists(table table: String, filters: [Filter]) -> Bool {
        print("exists \(filters.count) filters on \(table)")
        return false
    }

    public func count(table table: String, filters: [Filter]) -> Int {
        print("count \(filters.count) filters on \(table)")
        return 0
    }
}

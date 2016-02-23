import Fluent

public class PostgreSQLDriver: Fluent.Driver {
    private(set) var database: PostgreSQL!

    private init() {

    }

    public init(connectionInfo: String) {
        self.database = PostgreSQL(connectionInfo: connectionInfo)
            try! self.database.connect()
        }

    public func fetchOne(table table: String, filters: [Filter]) -> [String: String]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filters = filters
        sql.limit = 1

        let statement = self.database.createStatement(withQuery: sql.query)
        do {
          if try statement.execute() {
            if let data = dataFromResult(statement.result) {
              return data.first
            }
          }
        } catch { /* fail silently (for now) */ }
        return nil
    }

    public func fetch(table table: String, filters: [Filter]) -> [[String: String]] {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filters = filters
        let statement = self.database.createStatement(withQuery: sql.query)
        do {
          if try statement.execute() {
            if let data = dataFromResult(statement.result) {
              return data
            }
          }
        } catch { /* fail silently (for now) */ }
        return []
    }

    public func delete(table table: String, filters: [Filter]) {
        let sql = SQL(operation: .DELETE, table: table)
        sql.filters = filters

        let statement = self.database.createStatement(withQuery: sql.query)
        do {
          try statement.execute()
        } catch { /* fail silently (for now) */ }
    }

    public func update(table table: String, filters: [Filter], data: [String: String]) {
        let sql = SQL(operation: .UPDATE, table: table)
        sql.filters = filters
        sql.data = data

        let statement = self.database.createStatement(withQuery: sql.query)
        do {
          try statement.execute()
        } catch { /* fail silently (for now) */ }
    }

    public func insert(table table: String, items: [[String: String]]) {
      for item in items {
        let sql = SQL(operation: .INSERT, table: table)
        sql.data = item

        let statement = self.database.createStatement(withQuery: sql.query)
        do {
          try statement.execute()
        } catch { /* fail silently (for now) */ }
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

    // MARK: - Internal

    internal func dataFromResult(result: PSQLResult?) -> [[String: String]]? {
      guard let result = result else { return nil }
      if result.rowCount > 0 && result.columnCount > 0 {
        var data: [[String: String]] = []
        var row: Int = 0
        while row < result.rowCount {
            var item: [String: String] = [:]
            var column: Int = 0
            while column < result.columnCount {
                item[result.columnName(column) ?? ""] = result.stringAt(row, columnIndex: column)
                column += 1
            }
            data.append(item)
            row += 1
        }
        return data
      }
      return nil
    }
}
